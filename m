From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] sctp: change to use uint<size>_t in uapi sctp.h
Date: Wed, 15 Feb 2017 09:17:56 -0500
Message-ID: <20170215141756.GA24734@neilslaptop.think-freely.org>
References: <05fb9cd9aed85d33cc8d635a18b0dcd3e7c0ff29.1487060628.git.lucien.xin@gmail.com>
 <20170214.112604.827348279100654183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, marcelo.leitner@gmail.com,
        vyasevich@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56296 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750905AbdBOOSJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 09:18:09 -0500
Content-Disposition: inline
In-Reply-To: <20170214.112604.827348279100654183.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2017 at 11:26:04AM -0500, David Miller wrote:
> From: Xin Long <lucien.xin@gmail.com>
> Date: Tue, 14 Feb 2017 16:23:48 +0800
> 
> > All structures in uapi sctp.h are exported for userspace, their members'
> > types should use uint<size>_t instead of __u<size>.
> 
> This is not true.
> 
> __u<size> is in fact preferred for userspace exported datastructures.
> 

I'll admit that I can never remember which is which, but the files in uapi seem
pretty evenly split between the two types, and I always thought the uint<size>_t
was the one meant for user space

Neil
