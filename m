From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [patch] RFC: matching interface groups
Date: Thu, 03 Aug 2006 21:08:59 +0200
Message-ID: <1154632139.6333.5.camel@bzorp.balabit>
References: <1154452209.6395.77.camel@bzorp.balabit>
	 <17617.30375.336813.199864@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from balabit.hu ([82.141.167.23]:9893 "EHLO balabit.hu")
	by vger.kernel.org with ESMTP id S1030209AbWHCTJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 15:09:00 -0400
To: "Stephen J. Bevan" <stephen@dino.dnsalias.com>
In-Reply-To: <17617.30375.336813.199864@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-02 at 21:08 -0700, Stephen J. Bevan wrote:
> Balazs Scheidler writes:
>  > I would like to easily match a set of dynamically created interfaces
>  > from my packet filter rules. The attached patch forms the basis of my
>  > implementation and I would like to know whether something like this is
>  > mergeable to mainline.
> [snip]
>  > The implementation:
>  > 
>  > Each interface can belong to a single "group" at a time, an interface
>  > comes up without being a member in any of the groups.
> 
> You can get a similar effect by (ab)using the iflink field i.e. set
> the iflink to the parent interface and modify
> ip_tables.c:ip_packet_match to check the ifindex (or iflink if
> defined) for a match.  An advantage of this is that it doesn't require
> adding any new fields and the only kernel change is to
> ip_tables.c:ip_packet_match (and its caller).  That said, an explicit
> group (or zone as various firewall vendors call it) is cleaner.

I could hack a solution together, but I'd prefer to do this cleanly,
preferably as a patch in mainline. I would like to incorporate this
functionality in our product.

-- 
Bazsi

