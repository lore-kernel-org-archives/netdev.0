From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] locking bug in fib_semantics.c
Date: Wed, 23 Aug 2006 08:34:06 +0200
Message-ID: <20060823063406.GA1948@ff.dom.local>
References: <20060817093615.GA25553@ms2.inr.ac.ru> <20060821081642.GA2637@ff.dom.local> <20060821.011703.78716718.davem@davemloft.net> <20060821110201.GA3674@ff.dom.local> <20060822103556.GA3262@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:55979 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S932368AbWHWGbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 02:31:05 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060822103556.GA3262@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2006 at 12:35:56PM +0200, Jarek Poplawski wrote:
... 
> Hello,
> I've found it at last but on that occasion I've got some
> doubt according to rcu_read_lock and rcu_call treatment:
...

Actually there is one more doubt (bug really, but
not very probable): proc file reading is without any
locking in fib_hash.c, so if somebody uses programs
which do that often, he could have problems while
adding or deleting a route in a wrong time. If it
will be ever changed, fz_nent should also be ++/--
under lock, I think. 

Jarek P.
 
PS: linux-2.6.18-rc4
