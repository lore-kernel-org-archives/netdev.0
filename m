From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2.6.17] support for TSO over IPv6
Date: Thu, 29 Jun 2006 19:06:51 -0700
Message-ID: <1151633211.21798.25.camel@rh4>
References: <Pine.GSO.4.10.10606291810490.12773-100000@guinness>
 <E1Fw604-0006yP-00@gondolin.me.apana.org.au>
 <20060630003906.GA27200@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ananda Raju" <Ananda.Raju@neterion.com>, netdev@vger.kernel.org,
	jgarzik@pobox.com, shemminger@osdl.org,
	Leonid.Grossman@neterion.com, Ravinandan.Arakali@neterion.com,
	sivakumar.subramani@neterion.com, Sriram.Rapuru@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:56588 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1750787AbWF3CGU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 22:06:20 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060630003906.GA27200@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-06-30 at 10:39 +1000, Herbert Xu wrote:

> BTW, does your card handle ECN correctly? If not then we should change
> the new ECN bit to apply to both TCPv4 and TCPv6 since
> 
> 1) We now have a piece of hardware that handles TSO6 and it doesn't do ECN.
> 2) It's quite likely that if the NIC can handle ECN in TCPv4 then it can do
>    it in TCPv6.

Don't we have a bigger problem if it doesn't support ECN with ipv6 TSO?
We either have to disable ECN when TSO is enabled like we used to for
ipv4, or provide the gso tcp segmentation for ipv6.  Right?

