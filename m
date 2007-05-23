From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [NET] meth driver renovation
Date: Wed, 23 May 2007 09:44:24 +0100
Message-ID: <20070523084424.GA5083@linux-mips.org>
References: <20070523084330.GA4966@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:43986 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756751AbXEWIoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 04:44:38 -0400
Received: from localhost.localdomain ([127.0.0.1]:41416 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021510AbXEWIoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 09:44:37 +0100
Content-Disposition: inline
In-Reply-To: <20070523084330.GA4966@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 23, 2007 at 09:43:30AM +0100, Ralf Baechle wrote:

> The meth ethernet driver for the SGI IP32 aka O2 is so far still an old
> style driver which does not use the device driver model.  This is now
> causing issues with some udev based gadgetry in debian-stable.  Fixed by
> converting the meth driver to a platform device.

Since this seems to cause some real world problems I'd like to get this
patch into 2.6.22.

  Ralf
