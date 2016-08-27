From: Oleg Drokin <green@linuxhacker.ru>
Subject: Re: [PATCH] bridge: Fix format string for %ul
Date: Sat, 27 Aug 2016 11:58:00 -0400
Message-ID: <95BF7F27-59F7-4BDA-941B-BB00C60423A4@linuxhacker.ru>
References: <1472267428-810527-1-git-send-email-green@linuxhacker.ru> <11e50e3c-2e1f-4614-07e3-3bd144af4f94@cogentembedded.com>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <11e50e3c-2e1f-4614-07e3-3bd144af4f94@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Aug 27, 2016, at 11:13 AM, Sergei Shtylyov wrote:

> Hello.
> 
> On 8/27/2016 6:10 AM, Oleg Drokin wrote:
> 
>> %ul would print an unsigned value and a letter l,
>> likely it was %lu that was meant to print the long int,
>> but in reality the values printed there are just regular signed
> 
>   Signed? Then you need probably "%d" or "%i"…

They are signed in the struct definition, but in reality they
designate time, so could not be negative, I imagine?

> 
>> ints, so just dropping the l altogether.
>> 
>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> [...]
> 
> MBR, Sergei
