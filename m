From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH 2/2] tcp: Early SYN limit and SYN cookie handling to mitigate SYN floods
Date: Thu, 31 May 2012 17:31:55 +0200
Message-ID: <201205311731.57159.hans.schillstrom@ericsson.com>
References: <20120528115102.12068.79994.stgit@localhost.localdomain> <201205311045.03556.hans.schillstrom@ericsson.com> <1338473361.2760.1361.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, Andi Kleen <andi@firstfloor.org>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:50502 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932349Ab2EaPcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 11:32:04 -0400
In-Reply-To: <1338473361.2760.1361.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 31 May 2012 16:09:21 Eric Dumazet wrote:
> On Thu, 2012-05-31 at 10:45 +0200, Hans Schillstrom wrote:
> 
> > I can see plenty "IPv4: dst cache overflow"
> > 
> 
> This is probably the most problematic problem in DDOS attacks.
> 
> I have a patch for this problem.
> 
> Idea is to not cache dst entries for following cases :
> 
> 1) Input dst, if listener queue is full (syncookies possibly engaged)
> 
> 2) Output dst of SYNACK messages.
> 
Sound like a good idea, 
if you need some testing just the patches 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
