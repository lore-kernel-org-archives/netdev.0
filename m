From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Thu, 19 Oct 2006 19:59:21 -0700 (PDT)
Message-ID: <20061019.195921.31639913.davem@davemloft.net>
References: <17718.63424.509719.492216@localhost.localdomain>
	<eh87aq$71t$1@sea.gmane.org>
	<17720.12801.843076.819750@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pjf@asn.pl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20148
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S2992440AbWJTC7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 22:59:20 -0400
To: stephen@dino.dnsalias.com
In-Reply-To: <17720.12801.843076.819750@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Date: Thu, 19 Oct 2006 19:18:41 -0700

> Pawel Foremski writes:
>  > Secondly, IPsec won't decrease MSS in TCP encapsulated in PPPoE
>  > traffic, for example. 
> 
> Various, commercial, IPsec products decrease the MSS for TCP
> encapsulated in PPPoE.  I've not checked the Linux 2.6 IPsec code to
> see if it does or if it can easily be made to.

Linux will for local TCP connections over IPSEC transports since it
knows the path MTU, for IPSEC gateways the source system will adjust
the MSS after it notes via path-MTU what the decreased MTU is.

I think this is just a big list of excuses for not using IPSEC as the
solution for whatever problem is trying to be solved.
