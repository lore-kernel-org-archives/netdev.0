From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
 entry
Date: Wed, 17 Dec 2008 13:31:31 -0800
Message-ID: <20081217133131.44a4f67f@extreme>
References: <20081211181528.GB10558@hmsendeavour.rdu.redhat.com>
	<20081211160307.20709435@s6510>
	<20081212121835.GA2402@hmsreliant.think-freely.org>
	<20081216.155540.34452478.davem@davemloft.net>
	<20081217211628.GD7356@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39107 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751759AbYLQVbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 16:31:34 -0500
In-Reply-To: <20081217211628.GD7356@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Dec 2008 16:16:28 -0500
Neil Horman <nhorman@tuxdriver.com> wrote:

> On Tue, Dec 16, 2008 at 03:55:40PM -0800, David Miller wrote:
> > From: Neil Horman <nhorman@tuxdriver.com>
> > Date: Fri, 12 Dec 2008 07:18:35 -0500
> > 
> > > On Thu, Dec 11, 2008 at 04:03:07PM -0800, Stephen Hemminger wrote:
> > > > I would ask it the other way. Why is interface an argument to netif_rx_complete
> > > > if it is never used?  
> > > > 
> > > Thats a fair question, and I don't know the answer, Dave?
> > 
> > That's just what the old code uses, since the NAPI context
> > sat inside of the device.  I just never removed it.
> 
> 
> To that end, Dave, I've got a tree with that api fixup complete.  Its on the
> napi_api_fixup branch of the tree here:
> http://git.infradead.org/users/nhorman/net-2.6.git?a=shortlog;h=refs/heads/napi_api_fixup
> 
> If you'd like to pull it, please go ahead, or I can submit individual patches
> for it, if you prefer
> 
> Regards
> Neil
> 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 

Since this a kernel API change, you have to do it as a one big patch
otherwise the kernel source won't build for the intermediate steps,
which makes 'git bisect' impossible.  Please merge the patches together.
