From: Tom Prince <tom.prince@ualberta.net>
Subject: Re: Fried r8169.
Date: Thu, 25 Oct 2007 20:29:26 -0400
Message-ID: <20071026002926.GA2650@hermes.priv>
References: <20071025154438.GA2673@hermes.priv> <20071025213645.GA2226@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:34663 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539AbXJZA0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 20:26:46 -0400
Received: by py-out-1112.google.com with SMTP id u77so1084358pyb
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2007 17:26:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20071025213645.GA2226@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 25, 2007 at 11:36:45PM +0200, Francois Romieu wrote:
> Tom Prince <tom.prince@ualberta.net> :
> > While testing Linux v2.6.24-rc1, I noticed that my onboard r8169 had
> > disappeared, and the it remained gone when I rebooted to v2.6.23 and v2.6.22,
> > where it had previously worked.
> 
> [...]
> > I am running x86_64 ASUS Z92T laptop (an OEM version of the A6T).
> > 
> > I have posted dmesg/lspci/config from v2.6.23 (and soon v2.6.24) at 
> >  www.math.uwo.ca/~rprince5/r8169/
> > 
> > Also these appear to be the relevant log messages from when the device was
> > working. Unfortunately, I didn't have the foresight to save dmesg/lspci from
> > before the device disappeared.
> 
> Can you try an older/vendor kernel and power-off the host before restarting ?
> 
> I have experienced something similar. My 8168b returns but the magic spell
> is still not clear.

Thanks.
 
Well, after power cyclic a few times, and reverting to v2.6.23, the card works
again. Unfortunately, I don't have the exact config where the card disappeared
any more, and it now shows up but doesn't work under v2.6.23. I'll spend some
time this weekend, and see if I can track down what causes it to disappear.

One data point: I have a kernel v2.6.23 + patch-2.6.23-rc9-hrt1 and a custom
acpi DSDT that seems to cause the device to disappear.

I have now uploaded dmesg/lspci/config from v2.6.23 from a succesful boot to
www.math.uwo.ca/~rprince5/r8169/

  Tom

