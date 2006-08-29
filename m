From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 4/6] net neighbour: convert to RCU
Date: Wed, 30 Aug 2006 03:36:07 +0400
Message-ID: <20060829233607.GA20359@ms2.inr.ac.ru>
References: <20060828230748.827712918@localhost.localdomain> <20060828230915.587544687@localhost.localdomain> <20060829152816.GA24283@ms2.inr.ac.ru> <20060829112204.0cf5e866@localhost.localdomain> <20060829211722.GA27855@ms2.inr.ac.ru> <20060829144608.012f0d60@dxpl.pdx.osdl.net> <20060829221606.GA10285@ms2.inr.ac.ru> <20060829160022.552d46e0@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:35783 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751461AbWH2XgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 19:36:13 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060829160022.552d46e0@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Yes, I forgot to say I take back my suggestion about atomic_inc_test_zero().
It would not work.

Seems, it is possible to add some barriers around setting n->dead
and testing it in neigh_lookup_rcu(), but it would be scary and ugly.
To be honest, I just do not know how to do this. :-)
