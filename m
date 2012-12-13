From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH v2] netfilter: nf_nat: Also handle non-ESTABLISHED routing
 changes in MASQUERADE
Date: Thu, 13 Dec 2012 09:19:27 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1212130918410.2048@blackhole.kfki.hu>
References: <1355358229-25167-1-git-send-email-bsderandrew@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Collins <bsderandrew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.kfki.hu ([148.6.0.26]:33841 "EHLO smtp1.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752802Ab2LMITb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 03:19:31 -0500
In-Reply-To: <1355358229-25167-1-git-send-email-bsderandrew@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012, Andrew Collins wrote:

> The MASQUERADE target now handles routing changes which affect
> the output interface of a connection, but only for ESTABLISHED
> connections.  It is also possible for NEW connections which
> already have a conntrack entry to be affected by routing changes.
> 
> This adds a check to drop entries in the NEW+conntrack state
> when the oif has changed.
> 
> Signed-off-by: Andrew Collins <bsderandrew@gmail.com>

Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
