From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] ipv4: fix lock usage in udp_ioctl
Date: Thu, 15 Jun 2006 12:52:08 +0200
Message-ID: <20060615105208.GA2934@elte.hu>
References: <20060614194305.GB10391@osiris.ibm.com> <E1FqeXX-0008OE-00@gondolin.me.apana.org.au> <20060615052806.GA19803@elte.hu> <20060615065531.GA10411@osiris.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	jgarzik@pobox.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, fpavlic@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:40621 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S964772AbWFOKxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 06:53:43 -0400
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060615065531.GA10411@osiris.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> How about the patch below? The warning goes away and I assume 
> "tmp_list" needs lockdep_reinit_key too, since it should have the same 
> locking rules as the rest of qeth's skb-queue management.

yeah, looks good.

	Ingo
