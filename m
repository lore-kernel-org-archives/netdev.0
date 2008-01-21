From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH 2/2] IPV6: RFC 2011 compatibility broken
Date: Mon, 21 Jan 2008 11:17:33 -0800
Message-ID: <OF59F912FF.880BB50C-ON882573D7.006992FD-882573D7.0069F925@us.ibm.com>
References: <47946A04.3080702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:45127 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbYAUTRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 14:17:45 -0500
In-Reply-To: <47946A04.3080702@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 2011 doesn't apply to IPv6, and the internal names of /proc entries
are not used by the SNMP protocol, but it is an unintentional 
incompatibility with the
previous Linux entry names, so I agree. :-)

                                        +-DLS

Acked-by: David L Stevens <dlstevens@us.ibm.com>

netdev-owner@vger.kernel.org wrote on 01/21/2008 01:46:44 AM:

> [IPV6]: RFC 2011 compatibility broken
> 
> The snmp6 entry name was changed, and it broke compatibility
> to RFC 2011.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
>
