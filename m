From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] route:ip_rt_frag_needed always return unzero
Date: Wed, 19 Oct 2011 10:38:32 +0200
Message-ID: <20111019083832.GT1830@secunet.com>
References: <1318921469-25599-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1318929797.2657.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <4E9E2929.7070701@cn.fujitsu.com>
 <1318996187.19139.8.camel@edumazet-laptop>
 <4E9E5E1C.5020603@cn.fujitsu.com>
 <20111019072628.GS1830@secunet.com>
 <4E9E8552.1050405@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57495 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752427Ab1JSIim (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 04:38:42 -0400
Content-Disposition: inline
In-Reply-To: <4E9E8552.1050405@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2011 at 04:07:46PM +0800, Gao feng wrote:
> 2011.10.19 15:26, Steffen Klassert wrote:
> 
> > 
> > It is valid in the sense that we should not provide the user
> > with a mtu information if we know that the value we got from
> > the icmp packet ist bogus. But perhaps we can think about
> > making the check for a valid mtu unconditionally and let
> > ip_rt_frag_needed return a valid mtu in any case.
> > 
> > 
> 
> I think we should return the pmtu in icmp packet to the raw socket,
> and the valid mtu to tcp_v4_err or something else.
> 

Why you want to handle raw sockets different here?
