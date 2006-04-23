From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: via_rhine/qdisc Dead loop on netdevice eth1, fix it urgently!
Date: Sun, 23 Apr 2006 21:31:07 +1000
Message-ID: <20060423113107.GA16193@gondor.apana.org.au>
References: <Pine.LNX.4.58.0604140935220.4085@ldap2.hardrock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2317 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751378AbWDWLbK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Apr 2006 07:31:10 -0400
To: James Bourne <jbourne@hardrock.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0604140935220.4085@ldap2.hardrock.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 14, 2006 at 03:51:15PM +0000, James Bourne wrote:
>
> Apr 14 08:32:54 bama kernel:  [<c02becbb>] netpoll_send_skb+0xa8/0x100     [<f8c4c174>] write_msg+0x140/0x181 [netconsole]

This is the culprit.  Disable that and the problem will go away.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
