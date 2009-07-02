From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (possibly
	caused by netem)
Date: Thu, 2 Jul 2009 11:43:46 +0000
Message-ID: <20090702114346.GB7402@ff.dom.local>
References: <4A4A9DD6.8060800@anarazel.de> <4A4BAD5F.7050908@gmail.com> <4A4BD384.3090407@anarazel.de> <4A4C0144.5070203@anarazel.de> <20090702093031.GC4954@ff.dom.local> <20090702101207.GA7056@ff.dom.local> <4A4C95FC.7040305@anarazel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Andres Freund <andres@anarazel.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752793AbZGBLoM@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A4C95FC.7040305@anarazel.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 02, 2009 at 01:11:56PM +0200, Andres Freund wrote:
> On 07/02/2009 12:12 PM, Jarek Poplawski wrote:
>> On Thu, Jul 02, 2009 at 09:30:31AM +0000, Jarek Poplawski wrote:
>>> On Thu, Jul 02, 2009 at 02:37:24AM +0200, Andres Freund wrote:
>>> ...
>>>> So I tried - and I did not catch any lockdep output before the crash.
>>>> Unfortunately I do not have another machine on the same local network to
>>>> catch any messages after the crash... So I could be missing some warning
>>>> (I did synchronous logging though).
>>>> Will check with netconsole tomorrow.
>>>
>>> Could you try if this patch changes anything?
>>
>> ...and maybe CONFIG_PACKET_MMAP turned off.
> Ok. Removed the skb_orphan and turned of CONFIG_PACKET_MMAP. Seemingly  
> the same game.
> I now had another computer to catch the netconsole output. Still no  
> lockdep warnings.
>
> Unfortunately the other computer was a windows machine with its strange  
> terminal, so long lines are wrapped at 80cols, but that shouldn't be too  
> bad.

It's very nice ;-) Alas we can see here only one side, so there is
still some searching needed. I hope I'll be able to reproduce this
later.

Thanks for your work Andres,
Jarek P.
