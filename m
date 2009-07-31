From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: select sane defaults for xfrm[4|6] gc_thresh
Date: Thu, 30 Jul 2009 18:34:30 -0700 (PDT)
Message-ID: <20090730.183430.122005044.davem@davemloft.net>
References: <20090730.142345.148651785.davem@davemloft.net>
	<20090730.142554.103113174.davem@davemloft.net>
	<20090731001102.GA6068@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51245
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751068AbZGaBeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 21:34:22 -0400
In-Reply-To: <20090731001102.GA6068@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 30 Jul 2009 20:11:02 -0400

> On Thu, Jul 30, 2009 at 02:25:54PM -0700, David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Thu, 30 Jul 2009 14:23:45 -0700 (PDT)
>> 
>> Actually I had to revert, how the heck did you build test
>> this? :-/
>> 
>> In file included from include/net/xfrm.h:21,
>>                  from net/ipv4/af_inet.c:113:
>> include/net/ip6_fib.h:28:1: warning: "FIB_TABLE_HASHSZ" redefined
>> In file included from net/ipv4/af_inet.c:102:
>> include/net/ip_fib.h:134:1: warning: this is the location of the previous definition
>> 
> 
> Thats bizzare, I've got it running on a system here at Red Hat if you want to
> take a look, it definatley built for me.  Sorry about that, let me figure out
> what went south and I'll repost.

Sorry, bad phrasing on my part.  It built, it just spits out those
warnings because ipv4 and ipv6 use the same macro name and it
gets redefined.
