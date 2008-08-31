From: "Nick Kossifidis" <mickflemm@gmail.com>
Subject: Re: [GIT]: Networking
Date: Sun, 31 Aug 2008 22:58:36 +0300
Message-ID: <40f31dec0808311258q7598dfe3he81b7575375faff5@mail.gmail.com>
References: <20080805.190020.244441681.davem@davemloft.net>
	 <alpine.LFD.1.10.0808051937410.15995@nehalem.linux-foundation.org>
	 <200808061021.56150.IvDoorn@gmail.com> <48B7CBA7.4060107@grupopie.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Ivo van Doorn" <ivdoorn@gmail.com>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
To: "Rui Santos" <rsantos@grupopie.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:40760 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756290AbYHaT6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2008 15:58:38 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1580674wfd.4
        for <netdev@vger.kernel.org>; Sun, 31 Aug 2008 12:58:37 -0700 (PDT)
In-Reply-To: <48B7CBA7.4060107@grupopie.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/8/29 Rui Santos <rsantos@grupopie.com>:
> Ivo van Doorn wrote:
>> On Wednesday 06 August 2008, Linus Torvalds wrote:
>>> On Tue, 5 Aug 2008, David Miller wrote:
>>>> There was going to be the addition of the ath9k wireless driver but
>>>> there was some fallout that is being worked on right now (linux/list.h
>>>> changes needed lkml review, ath9k driver triggered some gcc aborts,
>>>> all kinds of fun stuff :-) so hopefully it will make it in the next
>>>> pass.  I tried to wait an extra day for it to be resolved, but that
>>>> was optimistic.
>>> Talking about wireless driver updates - has anybody looked at the RaLink
>>> wireless driver?  It's in the newer EeePC's (901 and 1000), and it
>>> actually has a driver from the company which the comments make clear is
>>> GPLv2 too, no apparent oddness or anything:
>>>
>>>      http://www.ralinktech.com.tw/data/drivers/2008_0708_RT2860_Linux_STA_v1.7.0.0.tar.bz2
>>>
>>> which admittedly apparently has some trivial problems (with a trivial
>>> patch as seen at
>>>
>>>      http://fedoraforum.org/forum/showthread.php?t=195429
>>>
>>> I'd love to have that one working, since I have the hardware, and it's
>>> actually reasonable (much more so than the original EeePC, in fact). What
>>> channels should I go through? Is anybody working on integrating it
>>> already?
>>
>> Like the earlier rt2x00 drivers I am rewriting the driver as released by Ralink and
>> have put it in the rt2x00lib/mac80211 framework. Most of the code is currently done, and the
>> last part should be done this week. After that it is a matter of testing and comparing
>> register values with the Ralink driver for the last tweaks.
>
> Hi Ivo,
>
> I'm now a EeePc 901 owner. I'd also like to have wireless working on
> this machine.
> I'm available for any test you might want to undertake so, do not
> hesitate to ask.
>

EeePC is working, the patch series i submitted adds support for RF2425
chip which is included on EeePCs as far as i know (i have tested it on
an EeePC 900 surf, i think EeePC 901 has the same card) ;-)

We have some performance issues with ath5k but we are working on it
you can try and lock on b rates for better performance (we miss some
RF calibration stuff and CCK rates seem to perform better).

Happy wardriving ;-)

-- 
GPG ID: 0xD21DB2DB
As you read this post global entropy rises. Have Fun ;-)
Nick
