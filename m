From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH][IPSEC] fix panic when using inter address familiy IPsec
 on loopback
Date: Fri, 20 Apr 2007 10:18:23 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0704201017530.17134@d.namei>
References: <20070420190251.292bea8a.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Miika Komu <miika@iki.fi>,
	Diego Beltrami <Diego.Beltrami@hiit.fi>,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:39962 "EHLO
	mail5.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767110AbXDTOS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 10:18:27 -0400
In-Reply-To: <20070420190251.292bea8a.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Apr 2007, Kazunori MIYAZAWA wrote:

> Hello,
> 
> I send patches to fix panic when using inter
> address family IPsec on loopback device.
> 
> These patches can be applied to current linux-2.6 and
> should also be net-2.6.

Looks good to me, although I wonder why the !IFF_LOOPBACK check was there 
in the first place.



- James
-- 
James Morris
<jmorris@namei.org>
