From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/4] atl1: Build files for Attansic L1 driver
Date: Thu, 11 Jan 2007 09:19:13 +0000
Message-ID: <20070111091913.GA3141@infradead.org>
References: <20070111004051.GB2624@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, shemminger@osdl.org, csnook@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34613 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965337AbXAKJTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jan 2007 04:19:35 -0500
To: Jay Cliburn <jacliburn@bellsouth.net>
Content-Disposition: inline
In-Reply-To: <20070111004051.GB2624@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 10, 2007 at 06:40:51PM -0600, Jay Cliburn wrote:
> --- /dev/null
> +++ b/drivers/net/atl1/Makefile
> @@ -0,0 +1,30 @@
> +################################################################################
> +#
> +# Attansic L1 gigabit ethernet driver
> +# Copyright(c) 2005 - 2006 Attansic Corporation.
> +#
> +# This program is free software; you can redistribute it and/or modify it
> +# under the terms and conditions of the GNU General Public License,
> +# version 2, as published by the Free Software Foundation.
> +#
> +# This program is distributed in the hope it will be useful, but WITHOUT
> +# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> +# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> +# more details.
> +#
> +# You should have received a copy of the GNU General Public License along with
> +# this program; if not, write to the Free Software Foundation, Inc.,
> +# 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
> +#
> +# The full GNU General Public License is included in this distribution in
> +# the file called "COPYING".
> +#
> +################################################################################

I don't think anyone can claim copyright on two lines of actual kbuild code.

> +#
> +# Makefile for the Attansic L1 gigabit ethernet driver
> +#

This comment is antirely superflous.

> +obj-$(CONFIG_ATL1) += atl1.o
> +
> +atl1-objs := atl1_main.o atl1_hw.o atl1_ethtool.o atl1_param.o

Thi should be atl1-y += ...

In short the whole contents of this file should be:

---------------- snip ----------------
obj-$(CONFIG_ATL1)	+= atl1.o
atl1-y			+= atl1_main.o atl1_hw.o atl1_ethtool.o atl1_param.o
---------------- snip ----------------

