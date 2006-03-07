From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: de2104x: interrupts before interrupt handler is registered
Date: Tue, 7 Mar 2006 05:11:52 +0000
Message-ID: <20060307051152.GA1244@deprecation.cyrius.com>
References: <20060305180757.GA22121@deprecation.cyrius.com> <20060305185948.GA24765@electric-eye.fr.zoreil.com> <20060306143512.GI23669@deprecation.cyrius.com> <20060306191706.GA6947@deprecation.cyrius.com> <20060306211745.GD15728@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750920AbWCGFMJ@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060306211745.GD15728@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Francois Romieu <romieu@fr.zoreil.com> [2006-03-06 22:17]:
> Not sure about this one, but...

It seems to help.  It's hard to say for sure because I don't have a
foolproof way to reproduce this panic.  It _usually_ occurs after
copying a few hundred MB but there's no clear trigger.  I've now copied
a few GB around using a kernel with your patch and it hasn't crashed.
-- 
Martin Michlmayr
http://www.cyrius.com/
