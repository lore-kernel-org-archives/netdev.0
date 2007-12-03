From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: namespace support requires network modules to say "GPL"
Date: Mon, 03 Dec 2007 11:03:38 -0700
Message-ID: <m18x4b1wqt.fsf@ebiederm.dsl.xmission.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill>
	<20071201163035.321fd554@freepuppy.rosehill> <475227B1.2060802@rtr.ca>
	<1196670255.4127.21.camel@rukbat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Lord <lkml@rtr.ca>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: Romano Giannetti <romanol@upcomillas.es>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752576AbXLCSFZ@vger.kernel.org>
In-Reply-To: <1196670255.4127.21.camel@rukbat> (Romano Giannetti's message of
	"Mon, 03 Dec 2007 09:24:15 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Romano Giannetti <romanol@upcomillas.es> writes:

> Please pardon me for jumping in; I am not a kernel developer, but I try
> to help with debugging whenever I can (and it's not just hand-waving, I
> helped to track down a couple of nasty bugs on MMC or ACPI EC,
> recently). And I am an engineer and IANAL, so I wouldn't speak about
> laws here. But I think it's not just a distribution's problem.
>
> Unfortunately, I need VMware and ndiswrapper to get work done with my
> laptop. It's not the perfect world, but the only alternative is to boot
> in XP. So I normally stick with vendors kernels and, when I have time to
> "play" with new kernel, I go for it. If ndiswrapper and VMware work,
> perfect, I can test extensively the new kernel; if I find problems, I
> *know* I have to restart without proprietary modules, try to reproduce,
> report back. I did it a lot of times.
>
> What I think is that every time VMware or (worst) ndiswrapper breaks,
> the kernel loose an awful lot of testers. In the span of time before
> Giri and the VMware team post a patch (-rc1 and -rc4, tipically), my
> testing activity is just occasional. And I guess a lot of people is in
> the same situation. 
>
> These are just my 2cents. I will continue to test new kernels every time
> I can, and to use native solutions as often as I can (go, ath5k, go!;
> and LabWindows/CVI for Linux, anyone?). But maybe a bit of tolerance can
> help everyone...

As a kernel developer let me say thank you for doing what testing you can.

I think a bit of tolerance for others can help the conversation.  At the
same time since out of tree modules (even GPL'd ones) have not chosen
to play with us we have to move forward as best we can without their
input.  It isn't possible to do anything else.

Right now I have made some changes for good technical reasons, and
some out of tree modules have broken.  Regardless of the flavor of
EXPORT_SYMBOL they would have broken.

Based on my experience with in-tree code and the few glimpses I
have gotten of out of tree code the reason the out of tree code broke
is because it is doing very questionable things.

So the best I can say at this point, is my apologies that we have not
served you better and made it possible to do what you need to do
without relying on code of questionable character.  Hopefully this
situation will be better in the future.

Eric
