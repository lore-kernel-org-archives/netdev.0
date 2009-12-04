From: David Dillow <dave@thedillows.org>
Subject: Re: r8169 linux driver
Date: Fri, 04 Dec 2009 08:11:24 -0500
Message-ID: <1259932284.8163.221.camel@obelisk.thedillows.org>
References: <965280.19055.qm@web31808.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: michael.riepe@googlemail.com, netdev@vger.kernel.org
To: Philip Bordado <philipb@v-ecom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:57014 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754051AbZLDNR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2009 08:17:59 -0500
In-Reply-To: <965280.19055.qm@web31808.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added netdev to cc:, where you will get a broader depth of experience.

On Fri, 2009-12-04 at 04:40 -0800, Philip Bordado wrote:
> Did you guys manage to make the r8169 driver work on kernel version >= 2.6.29
> I'm having same problem, the network dies after a few seconds with huge file transfer or nfs transfer.
> I track the irq status but nothing unusual is happening, it just died with no error or nothing.
> So no way to debug :( I load the module using debug=16 as parameter.

I have no problems on anything 2.6.30-rc6 and beyond, but others have
had some issues with infinite loops in the driver that I don't think
were ever fully resolved. However, that doesn't sound like your problem.

It's unclear what kernels you've tried. You seem to imply that you've
tried kernels since 2.6.29, but what's the latest kernel you've tried
and had the issue with?

It will also help if you either send your dmesg output or 
dmesg | egrep '(XID|^Linux version)' so that we can see more details
about the hardware.

Dave

