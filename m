From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 02/10] IB/mlx5: Add support for extended query
 device
Date: Wed, 13 Aug 2014 16:49:37 +0300
Message-ID: <20140813134937.GA16343@mtldesk30>
References: <1407929951-16362-1-git-send-email-eli@mellanox.com>
 <1407929951-16362-3-git-send-email-eli@mellanox.com>
 <53EB5A0C.8040209@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roland@kernel.org, davem@davemloft.net, netdev@vger.kernel.org,
	rdma@vger.kernel.org, amirv@mellanox.com, yevgenyp@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:38963 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbaHMNtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 09:49:42 -0400
Received: by mail-we0-f176.google.com with SMTP id q58so11317689wes.7
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 06:49:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <53EB5A0C.8040209@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2014 at 04:29:00PM +0400, Sergei Shtylyov wrote:
> 
>   Why not just:
> 
> 	return query_device(device, attr);
> 
The compiler optimizes this anyway. If there will be a need to change
logic I will change this as well.
