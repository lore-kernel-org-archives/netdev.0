From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RFC 30/30] net: fec: consolidate hwtstamp implementation
Date: Sat, 21 Jun 2014 08:11:12 +0200
Message-ID: <20140621061112.GA3965@localhost.localdomain>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
 <E1Wxxhw-0005Yn-Ey@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org,
	Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:38889 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbaFUGLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2014 02:11:38 -0400
Received: by mail-we0-f178.google.com with SMTP id x48so4704866wes.9
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 23:11:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <E1Wxxhw-0005Yn-Ey@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 20, 2014 at 01:14:16PM +0100, Russell King wrote:
> Both transmit and receive use the same infrastructure for calculating
> the packet timestamp.  Rather than duplicating the code, provide a
> function to do this common work.  Model this function in the Intel
> e1000e version which avoids calling ns_to_ktime() within the spinlock;
> the spinlock is critical for timecounter_cyc2time() but not
> ns_to_ktime().

Thanks for cleaning this up.

Acked-by: Richard Cochran <richardcochran@gmail.com>
