From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH][MIPS][7/7] AR7: ethernet
Date: Thu, 13 Sep 2007 12:35:47 +0100
Message-ID: <20070913113547.GC31940@linux-mips.org>
References: <200709080143.12345.technoboy85@gmail.com> <200709080223.00613.technoboy85@gmail.com> <20070912165029.GG4571@linux-mips.org> <20070913014246.GB15247@networkno.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matteo Croce <technoboy85@gmail.com>, linux-mips@linux-mips.org,
	Eugene Konev <ejka@imfi.kspu.ru>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	openwrt-devel@lists.openwrt.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
To: Thiemo Seufer <ths@networkno.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:60533 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647AbXIMLgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 07:36:05 -0400
Received: from localhost.localdomain ([127.0.0.1]:55234 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021755AbXIMLgE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 12:36:04 +0100
Content-Disposition: inline
In-Reply-To: <20070913014246.GB15247@networkno.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 13, 2007 at 02:42:46AM +0100, Thiemo Seufer wrote:

> > All struct members here are sized such that there is no padding needed, so
> > the packed attribute doesn't buy you anything - unless of course the
> > entire structure is missaligned but I don't see how that would be possible
> > in this driver so the __attribute__ ((packed)) should go - it result in
> > somwhat larger and slower code.
> 
> FWIW, a modern gcc will warn about such superfluous packed attributes,
> that's another reason to remove those.

I doubt it will in this case; the packed structure is dereferenced by a
pointer so no way for gcc to know the alignment.

  Ralf
