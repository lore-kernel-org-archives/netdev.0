From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 08 May 2007 10:55:15 +0200
Message-ID: <46403AF3.9000300@wpkg.org>
References: <464034CF.20700@wpkg.org> <f19298770705080148u70638ac2ue87241382681088@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Michael Jones <mlj28@cam.ac.uk>,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965663AbXEHI4g@vger.kernel.org>
In-Reply-To: <f19298770705080148u70638ac2ue87241382681088@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Zaytsev schrieb:
> On 5/8/07, Tomasz Chmielewski <mangoo@wpkg.org> wrote:
>> Michael Jones wrote:
>>
>> >> +#ifndef __ARMEB__
>> >> +#warning Little endian mode not supported
>> >> +#endif
>> >
>> > Personally I'm less fussed about WAN / LE support. Anyone with any
>> > sense will run ixp4xx boards doing such a specialised network
>> > operation as BE. Also, NSLU2-Linux can't test this functionality with
>> > our LE setup as we don't have this hardware on-board. You may just
>> > want to declare a depends on ARMEB in Kconfig (with or without OR
>> > (ARM || BROKEN) ) and have done with it - it's up to you.
>>
>> Christian Hohnstaedt's work did support LE though.
>>
>> Not all ixp4xx boards are by definition "doing such a specialised
>> network operation".
>>
> 
> I was always curious, why do people want to run ixp4xx in LE mode? What
> are the benefits that overweight the obvious performance degradation?

I guess the main reason, at least for me, is that there is only one 
distro that properly supports LE ARM: Debian.

It greatly simplifies management/administration of a higher number of 
devices, given the fact that Debian also supports other architectures 
(not just x86/64, sometimes PPC, like most distros do).


Not always network performance is to most important factor.


-- 
Tomasz Chmielewski
http://wpkg.org
