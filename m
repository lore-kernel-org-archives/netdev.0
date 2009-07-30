From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: select sane defaults for xfrm[4|6] gc_thresh
Date: Thu, 30 Jul 2009 14:25:54 -0700 (PDT)
Message-ID: <20090730.142554.103113174.davem@davemloft.net>
References: <20090729003433.GA3414@localhost.localdomain>
	<20090730.142345.148651785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50812
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752945AbZG3VZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 17:25:46 -0400
In-Reply-To: <20090730.142345.148651785.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 30 Jul 2009 14:23:45 -0700 (PDT)

> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 28 Jul 2009 20:34:33 -0400
> 
>> Choose saner defaults for xfrm[4|6] gc_thresh values on init
> 
> Looks great, applied to net-next-2.6

Actually I had to revert, how the heck did you build test
this? :-/

In file included from include/net/xfrm.h:21,
                 from net/ipv4/af_inet.c:113:
include/net/ip6_fib.h:28:1: warning: "FIB_TABLE_HASHSZ" redefined
In file included from net/ipv4/af_inet.c:102:
include/net/ip_fib.h:134:1: warning: this is the location of the previous definition
