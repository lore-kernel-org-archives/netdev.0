From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
Subject: Re: forcedeth unknown events 0x21
Date: Sun, 11 Jan 2004 23:41:23 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4001D113.3030302@gmx.net>
References: <Pine.LNX.4.58.0312180952100.21042@kiku.itsise> <3FE6678B.5070006@gmx.net> <Pine.LNX.4.53.0401051456060.1039@alien>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Madis Janson <madis@ats.cyber.ee>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: madis <madis@cyber.ee>
In-Reply-To: <Pine.LNX.4.53.0401051456060.1039@alien>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

madis wrote:
> On Mon, 22 Dec 2003, Carl-Daniel Hailfinger wrote:
> 
>>Madis Janson wrote:
>>
>>>When trying forcedeth_2_6_patch_v19.txt, i got the following message
>>>fastly repeating after ifup eth0:
>>>
>>>"eth0: received irq with unknown events 0x21. Please report"
>>>
>>>and it didn't work eighter (ifup just stalled).
[...]
>>
>>Please try the attached patch on top of it and report back if it works.
> 
> the unknown events message disappeared,
> but the network did not start to work...

Do you use any powermanagement software (athcool, lvcool, fvcool, coolon,
athlon cooling patch, anything STPGNT related)? Does your BIOS list
anything STPGNT related?


> +               if (events & (NVREG_IRQ_RX_ERR)) {
> +                       dprintk(KERN_DEBUG "%s: received irq with events
> 0x%x.
> Probably RX fail.\n",
> +                                               dev->name, events);
> here were '}' missing.

Thanks for the hint.

If you see anything powermanagement related enabled, please disable it and
try again. Does that fix it?


Carl-Daniel
