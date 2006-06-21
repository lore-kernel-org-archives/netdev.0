From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 03/06] MLSXFRM: Add security sid to sock
Date: Wed, 21 Jun 2006 01:12:43 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606210111570.5693@d.namei>
References: <36282A1733C57546BE392885C06185920132401F@chaos.tcs.tcs-sec.com>
 <20060621043502.GA899@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:25305 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750864AbWFUFMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 01:12:46 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060621043502.GA899@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Jun 2006, Herbert Xu wrote:

> On Tue, Jun 20, 2006 at 08:50:55PM -0400, Venkat Yekkirala wrote:
> >
> > Nope. It would actually overwrite the pointer, so we put it away before
> > memcpy
> > and set it back after memcpy.
> 
> Right, I misread it as sptr = osk->sk_security.  Still, it'd be nice to
> optimise it away for the !SECURITY case.

Indeed, there should be zero overhead for core networking code when LSM is 
not configured.


- James
-- 
James Morris
<jmorris@namei.org>
