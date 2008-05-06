From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e: Add support for BM PHYs on ICH9
Date: Tue, 06 May 2008 12:18:48 -0400
Message-ID: <482084E8.70803@garzik.org>
References: <20080429161605.16923.73468.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45321 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752665AbYEFQSv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 12:18:51 -0400
In-Reply-To: <20080429161605.16923.73468.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> This patch adds support for the BM PHY, a new PHY model being used
> on ICH9-based implementations.
> 
> This new PHY exposes issues in the ICH9 silicon when receiving
> jumbo frames large enough to use more than a certain part of the
> Rx FIFO, and this unfortunately breaks packet split jumbo receives.
> For this reason we re-introduce (for affected adapters only) the
> jumbo single-skb receive routine back so that people who do
> wish to use jumbo frames on these ich9 platforms can do so.
> Part of this problem has to do with CPU sleep states and to make
> sure that all the wake up timings are correctly we force them
> with the recently merged pm_qos infrastructure written by Mark
> Gross. (See http://lkml.org/lkml/2007/10/4/400).
> 
> To make code read a bit easier we introduce a _IS_ICH flag so
> that we don't need to do mac type checks over the code.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

applied


