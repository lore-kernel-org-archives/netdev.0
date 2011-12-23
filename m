From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: RE: [PATCH v2] ARM: net: JIT compiler for packet filters
Date: Thu, 22 Dec 2011 21:26:47 -0500 (EST)
Message-ID: <alpine.LFD.2.02.1112222122100.2907@xanadu.home>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF25@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dave Martin <dave.martin@linaro.org>,
	Mircea Gherzan <mgherzan@gmail.com>, netdev@vger.kernel.org,
	linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:61506 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009Ab1LWC0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 21:26:50 -0500
Received: by qcqz2 with SMTP id z2so5351995qcq.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 18:26:50 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF25@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Dec 2011, David Laight wrote:

> > In principle, the condition could be __LINUX_ARM_ARCH__ < 5, since the
> > bx instruction is guaranteed to be available on all ARMv5 CPUs and
> > later (ARMv5T is not required).
> 
> Can't this code look at the actual cpu being used, and
> generate the relevant 'return' instruction?
> (Instead of trying to use some compile-time value.)

There is really no point doing so.  We intend to ultimately have a 
kernel that may support ARMv5 and lower, and another kernel to support 
ARMv6 and ARMv7.  So in a given context, either bx is always available 
(ARMv6+) or never required (ARMv5-).


Nicolas
