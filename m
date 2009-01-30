From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 09/13] atmel-mci: convert to dma_request_channel and
	down-level dma_slave
Date: Fri, 30 Jan 2009 16:02:24 -0700
Message-ID: <e9c3a7c20901301502h11f53eedvbe2b7617a8e123c1@mail.gmail.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	 <20081114213503.32354.21080.stgit@dwillia2-linux.ch.intel.com>
	 <20090131.014050.126762132.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:2267 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213AbZA3XCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 18:02:25 -0500
In-Reply-To: <20090131.014050.126762132.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 9:40 AM, Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:
> On Fri, 14 Nov 2008 14:35:03 -0700, Dan Williams <dan.j.williams@intel.com> wrote:
> How dw_dma_slave passed to the dw_dmac driver?  I cannot see where
> dwc->dws is initialized now.  Or am I missing something?
>

No, the conversion is incomplete.  After finding a channel that meets
the slave requirements it is up to the driver to set the slave data.
I will send a fix in a separate message.

Thanks for the review,
Dan
