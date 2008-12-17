From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
	entry
Date: Wed, 17 Dec 2008 16:16:28 -0500
Message-ID: <20081217211628.GD7356@hmsreliant.think-freely.org>
References: <20081211181528.GB10558@hmsendeavour.rdu.redhat.com> <20081211160307.20709435@s6510> <20081212121835.GA2402@hmsreliant.think-freely.org> <20081216.155540.34452478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48645 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbYLQVSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:18:34 -0500
Content-Disposition: inline
In-Reply-To: <20081216.155540.34452478.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 16, 2008 at 03:55:40PM -0800, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Fri, 12 Dec 2008 07:18:35 -0500
> 
> > On Thu, Dec 11, 2008 at 04:03:07PM -0800, Stephen Hemminger wrote:
> > > I would ask it the other way. Why is interface an argument to netif_rx_complete
> > > if it is never used?  
> > > 
> > Thats a fair question, and I don't know the answer, Dave?
> 
> That's just what the old code uses, since the NAPI context
> sat inside of the device.  I just never removed it.


To that end, Dave, I've got a tree with that api fixup complete.  Its on the
napi_api_fixup branch of the tree here:
http://git.infradead.org/users/nhorman/net-2.6.git?a=shortlog;h=refs/heads/napi_api_fixup

If you'd like to pull it, please go ahead, or I can submit individual patches
for it, if you prefer

Regards
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
