From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 1/10] cxgb3 - main header files
Date: Wed, 27 Dec 2006 10:03:57 +0100
Message-ID: <1167210238.3281.3751.camel@laptopd505.fenrus.org>
References: <20061220124125.6286.17148.stgit@localhost.localdomain>
	 <45918CA4.3020601@garzik.org>  <45923432.9040607@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Divy Le Ray <None@chelsio.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:33165 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754400AbWL0JEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 04:04:13 -0500
To: Divy Le Ray <divy@chelsio.com>
In-Reply-To: <45923432.9040607@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-27 at 00:52 -0800, Divy Le Ray wrote:
> Jeff,
> 
> You can grab the monolithic patch at this URL:
> http://service.chelsio.com/kernel.org/cxgb3.patch.bz2
> 
> This patch adds support for the latest 1G/10G Chelsio adapter, T3.
> It is required by the T3 RDMA driver Steve Wise submitted.


does this patch still contain all the private ioctls?
They are being ripped out from another new driver, and cxgb3 should
probably have the same treatment...


