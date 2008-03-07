From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [NET] ioc3.c: replace remaining __FUNCTION__ occurrences
Date: Fri, 7 Mar 2008 09:10:38 +0000
Message-ID: <20080307091038.GA30078@linux-mips.org>
References: <20080306155509.GA16365@linux-mips.org> <20080307001752.09a8b291.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Harvey Harrison <harvey.harrison@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:48616 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762040AbYCGJKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 04:10:43 -0500
Received: from localhost.localdomain ([127.0.0.1]:6369 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S28640654AbYCGJKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2008 09:10:41 +0000
Content-Disposition: inline
In-Reply-To: <20080307001752.09a8b291.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 07, 2008 at 12:17:52AM -0800, Andrew Morton wrote:

> On Thu, 6 Mar 2008 15:55:09 +0000 Ralf Baechle <ralf@linux-mips.org> wrote:
> 
> > From: Harvey Harrison <harvey.harrison@gmail.com>
> > 
> > __FUNCTION__ is gcc-specific, use __func__
> > 
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> > Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> >
> >  drivers/sn/ioc3.c |   22 +++++++++++-----------
> 
> this isn't a net driver is it?

-EFINGERSTOOFAST ;-)

(IOC3 is an everything and the kitchensink thing - ethernet, RTC, PS/2,
serial.)

Ralf
