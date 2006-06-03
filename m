From: David Daney <ddaney@avtrex.com>
Subject: Re: RFC3927 ARP patch status?
Date: Fri, 02 Jun 2006 17:55:17 -0700
Message-ID: <4480DDF5.2080002@avtrex.com>
References: <44806926.1050509@avtrex.com>	<E1FmIoI-0007nK-00@gondolin.me.apana.org.au>	<20060603003955.GJ549@progsoc.uts.edu.au> <20060602.174756.08320251.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wildfire@progsoc.uts.edu.au, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-116-42-147.dsl.sntc01.pacbell.net ([67.116.42.147]:36366
	"EHLO avtrex.com") by vger.kernel.org with ESMTP id S932590AbWFCAzS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 20:55:18 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060602.174756.08320251.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> RFC3927 seem to be an intellectual property mine field, I really don't
> see how we can include this in the Linux kernel.
> 
> Go to "http://www.ietf.org/ipr", click on "Search the IPR
> disclosures", then enter "3927" in the "Enter RFC number" field and
> click SEARCH.

RFC3927 may be a mine field, but the only thing that has to be changed 
in the kernel to support it is to somehow configure the arp driver to 
broadcast unconditionally on certain interfaces.  The majority of the 
rfc3927 protocol is done by userspace applications, so should *not* 
really effect the kernel.

David Daney.
