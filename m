From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make ipv4 multicast packets only get delivered to
 sockets that are joined to group
Date: Wed, 13 Sep 2006 18:09:48 -0700 (PDT)
Message-ID: <20060913.180948.74739586.davem@davemloft.net>
References: <OF0C86B64A.DE64FE98-ON882571E8.004F57A7-882571E8.004FDDED@us.ibm.com>
	<1158163943.15449.75.camel@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2268
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751297AbWINBI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 21:08:57 -0400
To: jlayton@poochiereds.net
In-Reply-To: <1158163943.15449.75.camel@dantu.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Layton <jlayton@poochiereds.net>
Date: Wed, 13 Sep 2006 12:12:23 -0400

> Most of the RFC's I've looked at don't seem to have much to say about
> how multicasting works at the socket level. Is there an RFC or
> specification that spells this out, or is this one of those situations
> where things are somewhat open to interpretation?

In these cases, whatever BSD does is effectively the definition of
what should happen since it is the "BSD socket API".
