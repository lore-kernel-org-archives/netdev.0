From: "Amit S. Kale" <amitkale@linsyssoft.com>
Subject: Re: [PATCH 0/9] Resending NetXen 1G/10G NIC driver patch
Date: Fri, 26 May 2006 11:16:49 +0530
Message-ID: <200605261116.50176.amitkale@linsyssoft.com>
References: <Pine.LNX.4.33.0605250339490.5844-100000@unmsrvr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sanjeev@unminc.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:27228 "EHLO
	svr68.ehostpros.com") by vger.kernel.org with ESMTP
	id S1030477AbWEZFrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 01:47:15 -0400
To: Stephen Hemminger <shemminger@osdl.org>,
	Roland Dreier <rdreier@cisco.com>
In-Reply-To: <Pine.LNX.4.33.0605250339490.5844-100000@unmsrvr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen, Roland,

Thanks a lot for feedback.

We'll implement the minor changes rightaway and post an update. We are also 
thinking about what's the best way to incorporate the data structure changes 
you have suggested. Will post a reply on that too soon.

-Amit

On Thursday 25 May 2006 16:15, Linsys Contractor Amit S. Kale wrote:
> Hi,
>
> I'll be sending a NetXen (formerly Universal Network Machines) 1G/10G in
> subsequent emails. This is a revised version of the UNM driver posted
> earlier. We have tried to make changes as per the feedback received.
> We would like this driver to be inluded in mainline kernel.
> Kindly review it and feel free to get back to me for any further
> feedback/queries/comments.
>
> Thanks.
> -Amit
>
> Signed-off-by: Amit S. Kale <amitkale@unminc.com>
>
>  Kconfig                      |    5
>  Makefile                     |    1
>  netxen/Makefile              |   35 +
>  netxen/netxen_nic.h          |  950 +++++++++++++++++++++++++++++++
>  netxen/netxen_nic_ethtool.c  |  802 ++++++++++++++++++++++++++
>  netxen/netxen_nic_hdr.h      |  682 ++++++++++++++++++++++
>  netxen/netxen_nic_hw.c       | 1289
> +++++++++++++++++++++++++++++++++++++++++++ netxen/netxen_nic_hw.h       | 
> 339 +++++++++++
>  netxen/netxen_nic_init.c     | 1219
> ++++++++++++++++++++++++++++++++++++++++ netxen/netxen_nic_ioctl.h    |  
> 75 ++
>  netxen/netxen_nic_isr.c      |  428 ++++++++++++++
>  netxen/netxen_nic_main.c     | 1209
> ++++++++++++++++++++++++++++++++++++++++ netxen/netxen_nic_niu.c      | 
> 770 +++++++++++++++++++++++++
>  netxen/netxen_nic_phan_reg.h |  195 ++++++
>  14 files changed, 7999 insertions(+)
