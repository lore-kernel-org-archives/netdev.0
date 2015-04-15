From: Honggang LI <honli@redhat.com>
Subject: Re: [PATCH linux-next v2] mlx5: wrong page mask if
 CONFIG_ARCH_DMA_ADDR_T_64BIT enabled for 32Bit architectures
Date: Wed, 15 Apr 2015 11:12:03 +0800
Message-ID: <20150415031203.GA4881@honli.nay.redhat.com>
References: <1428916918-24404-1-git-send-email-honli@redhat.com>
 <20150414192316.GB27750@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753761AbbDODMM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 23:12:12 -0400
Content-Disposition: inline
In-Reply-To: <20150414192316.GB27750@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2015 at 10:23:16PM +0300, Eli Cohen wrote:
> On Mon, Apr 13, 2015 at 05:21:58PM +0800, Honggang Li wrote:
> > @@ -241,7 +243,7 @@ static void free_4k(struct mlx5_core_dev *dev, u64 addr)
> >  static int alloc_system_page(struct mlx5_core_dev *dev, u16 func_id)
> >  {
> >  	struct page *page;
> > -	u64 addr;
> > +	u64 addr = 0;
> >  	int err;
> >  	int nid = dev_to_node(&dev->pdev->dev);
> >  
> 
> I really don't see any reason why you need to set addr to 0. Can you
> please explain this?
> Other than that the patch is ok.

Sorry, I trid my best to explain it. But failed. I'm fine to remove it.
New patch will be submit. And I will insert a fix tag in it.

Fix(bf0bf77 mlx5: Support communicating arbitrary host page size to
firmware)

thanks
