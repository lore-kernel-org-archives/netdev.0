From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: de2104x: interrupts before interrupt handler is registered
Date: Wed, 8 Mar 2006 01:15:56 +0100
Message-ID: <20060308001556.GA9362@electric-eye.fr.zoreil.com>
References: <20060305180757.GA22121@deprecation.cyrius.com> <20060305185948.GA24765@electric-eye.fr.zoreil.com> <20060306143512.GI23669@deprecation.cyrius.com> <20060306191706.GA6947@deprecation.cyrius.com> <20060306211745.GD15728@electric-eye.fr.zoreil.com> <20060307051152.GA1244@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751711AbWCHAUG@vger.kernel.org>
To: Martin Michlmayr <tbm@cyrius.com>
Content-Disposition: inline
In-Reply-To: <20060307051152.GA1244@deprecation.cyrius.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin Michlmayr <tbm@cyrius.com> :
[...]
> It seems to help.  It's hard to say for sure because I don't have a
> foolproof way to reproduce this panic.  It _usually_ occurs after
> copying a few hundred MB but there's no clear trigger.  I've now copied
> a few GB around using a kernel with your patch and it hasn't crashed.

netdev watchdog events appear in the dmesg of the patched driver.
The driver survived it. So I'd say that the patch does its job.

OTOH, if you ever saw the unpatched driver survive this event, yell now.

-- 
Ueimor
