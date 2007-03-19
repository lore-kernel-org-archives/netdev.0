From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Mon, 19 Mar 2007 11:33:15 +0200
Message-ID: <20070319093315.GA15909@mellanox.co.il>
References: <20070318155532.GG7958@mellanox.co.il>
	<20070318191238.GA20518@ms2.inr.ac.ru>
	<20070318202559.GD11078@mellanox.co.il>
	<m3tzwi8a20.fsf@maxwell.lnxi.com>
	<20070318223653.GO11078@mellanox.co.il>
	<20070318224234.GP11078@mellanox.co.il>
	<20070319092422.GB9387@ms2.inr.ac.ru>
Reply-To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>,
	"Eric W. Biederman" <ebiederman@lnxi.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	general@lists.openfabrics.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:59125 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416AbXCSJce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 05:32:34 -0400
Received: by ug-out-1314.google.com with SMTP id 44so1267678uga
        for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 02:32:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070319092422.GB9387@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Quoting Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>:
> Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
> 
> > Does this look sane (untested)?
> 
> It does not, unfortunately.
> 
> Instead of regular crash in infiniband you will get numerous
> random NULL pointer dereferences both due to dst->neighbour
> and due to dst->dev.

Right, I saw this clearly in the morning. Thanks.

-- 
MST
