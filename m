From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next v2] xfrm: allow to avoid copying DSCP during
 encapsulation
Date: Thu, 7 Mar 2013 08:46:27 +0100
Message-ID: <20130307074626.GB21448@secunet.com>
References: <20130222060644.GH17794@secunet.com>
 <1361526894-4104-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53836 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751485Ab3CGHq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 02:46:29 -0500
Content-Disposition: inline
In-Reply-To: <1361526894-4104-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 22, 2013 at 10:54:54AM +0100, Nicolas Dichtel wrote:
> By default, DSCP is copying during encapsulation.
> Copying the DSCP in IPsec tunneling may be a bit dangerous because packets with
> different DSCP may get reordered relative to each other in the network and then
> dropped by the remote IPsec GW if the reordering becomes too big compared to the
> replay window.
> 
> It is possible to avoid this copy with netfilter rules, but it's very convenient
> to be able to configure it for each SA directly.
> 
> This patch adds a toogle for this purpose. By default, it's not set to maintain
> backward compatibility.
> 
> Field flags in struct xfrm_usersa_info is full, hence I add a new attribute.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied to ipsec-next, thanks!
