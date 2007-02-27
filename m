From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 7/7] cxgb3 - Add SW LRO support
Date: Tue, 27 Feb 2007 08:57:26 -0600
Message-ID: <1172588246.11870.24.camel@stevo-desktop>
References: <20070225004423.20903.17036.stgit@localhost.localdomain>
	 <20070226051304.GA13626@infradead.org>
	 <1172585835.11870.13.camel@stevo-desktop>  <45E445D2.2090900@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>, divy@chelsio.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:60069 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752485AbXB0O52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 09:57:28 -0500
In-Reply-To: <45E445D2.2090900@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-02-27 at 09:53 -0500, Jeff Garzik wrote:
> Steve Wise wrote:
> > On Mon, 2007-02-26 at 05:13 +0000, Christoph Hellwig wrote:
> >> On Sat, Feb 24, 2007 at 04:44:23PM -0800, divy@chelsio.com wrote:
> >>> From: Divy Le Ray <divy@chelsio.com>
> >>>
> >>> Add all-in-sw lro support.
> >> Doing this in a LLDD doesn't sound like a good idea.  Have you
> >> tried doing this in the core networking code instead?
> > 
> > It looks like both Netxen and Neterion drivers already have this.  So I
> > think for now the LLDD implements LRO.  The stack supports it by virtue
> 
> That's argument to further avoiding compounding the problem, by 
> reinventing the wheel for each driver.

You're right.  But cxgb3 has it now in the driver (tested and working).
Shouldn't it be pulled in?  When the network stack design gets done
(which could take a few releases to finalize), all the drivers can be
updated to use it.  It doesn't seem reasonable to allow some drivers to
support LRO and others to not support it...


Steve.



