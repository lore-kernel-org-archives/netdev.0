From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC ipsec-next] xfrm: Add sysctl option to enforce
 inbound policies for transport mode
Date: Mon, 29 Sep 2014 21:46:08 +0800
Message-ID: <20140929134608.GA3189@gondor.apana.org.au>
References: <541815C3.7080509@strongswan.org>
 <20140919092437.GX6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tobias Brunner <tobias@strongswan.org>, davem@davemloft.net,
	netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:43983 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753498AbaI2NqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 09:46:24 -0400
Content-Disposition: inline
In-Reply-To: <20140919092437.GX6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 11:24:38AM +0200, Steffen Klassert wrote:
> Ccing Herbert Xu.
> 
> On Tue, Sep 16, 2014 at 12:49:39PM +0200, Tobias Brunner wrote:
> > Currently inbound policies for transport mode SAs are not enforced.
> > If no policy is found or if the templates don't match this is not
> > considered an error for transport mode SAs.
> > 
> 
> The strict inbound policy enforcement was implemented by Herbert.
> The commit predates our git history but can be found in the history
> tree:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git
> 
> It was the following commit:
> 
> commit 8fe7ee2ba983fd89b2555dce5930ffd0f7f6c361
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Thu Oct 23 14:57:11 2003 -0700
> 
>     [IPSEC]: Strengthen policy checks.
> 
> Maybe Herbert remembers why this was done only for tunnel mode.

Yes I remember :) Please refer to the following thread:

http://www.spinics.net/lists/linux-net/msg07342.html

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
