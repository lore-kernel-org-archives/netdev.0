From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] xfrm: select sane defaults for xfrm[4|6] gc_thresh
Date: Thu, 30 Jul 2009 20:11:02 -0400
Message-ID: <20090731001102.GA6068@localhost.localdomain>
References: <20090729003433.GA3414@localhost.localdomain> <20090730.142345.148651785.davem@davemloft.net> <20090730.142554.103113174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44405 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938AbZGaALP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 20:11:15 -0400
Content-Disposition: inline
In-Reply-To: <20090730.142554.103113174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 30, 2009 at 02:25:54PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 30 Jul 2009 14:23:45 -0700 (PDT)
> 
> > From: Neil Horman <nhorman@tuxdriver.com>
> > Date: Tue, 28 Jul 2009 20:34:33 -0400
> > 
> >> Choose saner defaults for xfrm[4|6] gc_thresh values on init
> > 
> > Looks great, applied to net-next-2.6
> 
> Actually I had to revert, how the heck did you build test
> this? :-/
> 
> In file included from include/net/xfrm.h:21,
>                  from net/ipv4/af_inet.c:113:
> include/net/ip6_fib.h:28:1: warning: "FIB_TABLE_HASHSZ" redefined
> In file included from net/ipv4/af_inet.c:102:
> include/net/ip_fib.h:134:1: warning: this is the location of the previous definition
> 

Thats bizzare, I've got it running on a system here at Red Hat if you want to
take a look, it definatley built for me.  Sorry about that, let me figure out
what went south and I'll repost.

Neil

