From: Dave Jones <davej@redhat.com>
Subject: Re: PROBLEM: SIS900 Driver change in Linux Kernel 2.6.21 causes kernel panic.
Date: Wed, 16 May 2007 18:17:04 -0400
Message-ID: <20070516221704.GC16810@redhat.com>
References: <577536.90963.qm@web84207.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniele Venzano <venza@brownhat.org>, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org
To: - <kd6lvw@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55722 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755456AbXEPWTi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 18:19:38 -0400
Content-Disposition: inline
In-Reply-To: <577536.90963.qm@web84207.mail.re3.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 16, 2007 at 02:33:18PM -0700, - wrote:
 > Kernel version 2.6.20.4 works.  What I'm experiencing is a kernel panic as
 > soon as the first received packet comes in via the sis900 ethernet
 > interface.  The machine is locked up and part of the kernel panic message
 > is lost as it has scrolled off the screen and the virtual terminal has
 > crashed as well (the kernel appears to have done a permanent halt - the
 > keyboard LEDs are flashing).  The only way I could get the machine to boot
 > without this problem was to unplug the ethernet cable - but it would
 > appear as soon as the the first packet was received after plugging the
 > cable back in.  That's not good since the machine in question is a server
 > in a co-location facility (I can't print the screen either).  The kernel
 > panic was repeatable without fail.  As this usually happens before "init"
 > is called, the only "program" running is the kernel itself.  I don't have
 > any syslog/dmesg message recorded to disk for the event.  I've rolled back
 > to version 2.6.20.4 in the meantime.

You need this..

http://git.kernel.org/?p=linux%2Fkernel%2Fgit%2Ftorvalds%2Flinux-2.6.git;a=commitdiff_plain;h=dc5a144991ba803bc8afded105c9db1dea0e57ab

Which is queued for -stable afaik, but no sign of 2.6.21.2 yet. Greg/Chris?

	Dave

-- 
http://www.codemonkey.org.uk
