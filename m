From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: skb header allocation
Date: Thu, 3 Sep 2009 16:23:44 -0700
Message-ID: <20090903162344.108374cb@nehalam>
References: <17cd85320908252004r31874732n9e06921d6eae4ad7@mail.gmail.com>
	<20090825201514.0dd143ad@nehalam>
	<4A94CFB3.4020706@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Ross <chris@compilednetworks.com>, netdev@vger.kernel.org
To: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44902 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756569AbZICXXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 19:23:48 -0400
In-Reply-To: <4A94CFB3.4020706@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Aug 2009 08:01:23 +0200
Frank Blaschka <blaschka@linux.vnet.ibm.com> wrote:

> Is it save to change dev->hard_header_len to a value other than ETH_HLEN for
> an ethernet device?
> 
> I rememeber we run in trouble with some kernel components (netfilter?, I'm
> not sure can't remember the details ...) when we did this is the past.
> 

You can add extra data but need a minimum with ETH_HLEN of space above
packet when receiving.


-- 
