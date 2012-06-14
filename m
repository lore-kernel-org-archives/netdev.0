From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Thu, 14 Jun 2012 07:58:55 +0200
Message-ID: <20120614055855.GR27795@secunet.com>
References: <20120613100709.GO27795@secunet.com>
 <20120613.032228.1574539964049471628.davem@davemloft.net>
 <20120614053529.GP27795@secunet.com>
 <20120613.224203.297717896085583687.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45608 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751006Ab2FNF7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 01:59:03 -0400
Content-Disposition: inline
In-Reply-To: <20120613.224203.297717896085583687.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 13, 2012 at 10:42:03PM -0700, David Miller wrote:
> 
> Ok, then if we want to do the fragmentation locally then we have to
> consider my initial patch which updates the PMTU in raw_err().
> 
> Did you test that?  I mean specifically, this patch:
> 
> http://marc.info/?l=linux-netdev&m=133945597319917&w=2
> 
> If it works for you, I will try to extend it to the other datagram
> cases.
> 

Yes, I can confirm that this one works. It restores the old behaviour.
