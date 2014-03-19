From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] micrel: fix masking off LED bits
Date: Wed, 19 Mar 2014 09:21:26 -0700
Message-ID: <CAGVrzcZd6rx0dbAdtqk3pbjuTVr4vwFqsRJxgc+dTQ0imnY57Q@mail.gmail.com>
References: <201403190258.16812.sergei.shtylyov@cogentembedded.com> <53295171.3020700@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <53295171.3020700@codethink.co.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-03-19 1:12 GMT-07:00 Ben Dooks <ben.dooks@codethink.co.uk>:
> On 19/03/14 00:58, Sergei Shtylyov wrote:
>>
>> Commit 20d8435a1cff (phy: micrel: add of configuration for LED mode) made
>> the
>> obvious mistake when masking off  the LED mode bits: forgot to do a
>> logical NOT
>> to the mask with which it ANDs the register value, so that unrelated bits
>> are
>> cleared instead.
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
> Acked-by: Ben Dooks <ben.dooks@codethink.co.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
