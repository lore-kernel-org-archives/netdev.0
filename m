From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH 2.6.20] ibm_emac: Use ARRAY_SIZE macro when appropriate
Date: Tue, 6 Feb 2007 11:12:07 +0200
Message-ID: <20070206091207.GR3896@Ahmed>
References: <20070205165429.GD3896@Ahmed> <20070205165916.GK3896@Ahmed> <20070205202206.GD11055@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebs@ebshome.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:17948 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbXBFJMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 04:12:23 -0500
Received: by wr-out-0506.google.com with SMTP id 68so1468076wri
        for <netdev@vger.kernel.org>; Tue, 06 Feb 2007 01:12:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20070205202206.GD11055@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 05, 2007 at 11:22:06PM +0300, Alexey Dobriyan wrote:
> On Mon, Feb 05, 2007 at 06:59:16PM +0200, Ahmed S. Darwish wrote:
> > A patch to use ARRAY_SIZE macro already defined in kernel.h.
> 
> OK, but checks you're changing are strange. idx there is signed so
> 
> 	BUG_ON(idx < 0 || idx > ARRAY_SIZE());
> 
> should be more appropriate.

It's just a janitor patch. I don't like to mess with code logic in such
kind of patches (to minimize errors and because I can't find time to
understand all affected files since they are scattered allover the tree).

Thanks,
-- 
Ahmed S. Darwish
http://darwish-07.blogspot.com
