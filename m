From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix compat_sock_common_getsockopt typo
Date: Tue, 06 Mar 2007 13:44:30 -0800 (PST)
Message-ID: <20070306.134430.45512920.davem@davemloft.net>
References: <Line.LNX.4.64.0703060942180.22674@d.namei>
	<1173192336.5415.5.camel@johannes.berg>
	<Line.LNX.4.64.0703061005420.22674@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50779
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751298AbXCFVoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 16:44:34 -0500
In-Reply-To: <Line.LNX.4.64.0703061005420.22674@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Tue, 6 Mar 2007 10:06:00 -0500 (EST)

> On Tue, 6 Mar 2007, Johannes Berg wrote:
> 
> > This patch fixes a typo in compat_sock_common_getsockopt.
> > 
> > Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> > 
> > --- wireless-dev.orig/net/core/sock.c	2007-03-06 15:44:15.618565674 +0100
> > +++ wireless-dev/net/core/sock.c	2007-03-06 15:44:25.948565674 +0100
> > @@ -1597,7 +1597,7 @@ int compat_sock_common_getsockopt(struct
> >  {
> >  	struct sock *sk = sock->sk;
> >  
> > -	if (sk->sk_prot->compat_setsockopt != NULL)
> > +	if (sk->sk_prot->compat_getsockopt != NULL)
> >  		return sk->sk_prot->compat_getsockopt(sk, level, optname,
> >  						      optval, optlen);
> >  	return sk->sk_prot->getsockopt(sk, level, optname, optval, optlen);
> 
> 
> Acked-by: James Morris <jmorris@namei.org>

Applied, thanks evryone.
