From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH] net/core: use net_device dev_id to indicate port number
Date: Wed, 26 May 2010 18:27:30 +0300
Message-ID: <20100526152730.GA10890@mtldesk030.lab.mtl.com>
References: <20100526095200.GA7370@mtldesk030.lab.mtl.com>
	<20100526082306.25959fb6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eli Cohen <eli@mellanox.co.il>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	rdreier@cisco.com, yevgenyp@mellanox.co.il
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:36891 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755211Ab0EZP1W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 11:27:22 -0400
Content-Disposition: inline
In-Reply-To: <20100526082306.25959fb6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 26, 2010 at 08:23:06AM -0700, Stephen Hemminger wrote:
> On Wed, 26 May 2010 12:52:00 +0300
> Eli Cohen <eli@mellanox.co.il> wrote:
> 
> > Today, there are no means to know which port of a hardware device a netdev
> > interface uses. struct net_device conatins a field, dev_id, that can be used
> > for that. This patch adds a new macro, SET_NETDEV_DEV_ID(), to provide a
> > standard way to set the value of this field.
> > Also also make use of this feature in the mlx4_en driver to set the port
> > number; port numbers are zero based.
> 
> Why is a macro wrapper needed?
> 

I guess for the same reason we use SET_NETDEV_DEV - to provide a
consistent interface for setting this value...
