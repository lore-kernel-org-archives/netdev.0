From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: airo: inconsistent {hardirq-on-W} -> {in-hardirq-W} usage.
Date: Tue, 8 Aug 2006 14:38:51 +0300
Message-ID: <20060808113851.GA17861@ee.oulu.fi>
References: <20060808094410.GA29313@ee.oulu.fi> <E1GAPZF-0003w4-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:62205 "EHLO ee.oulu.fi")
	by vger.kernel.org with ESMTP id S964861AbWHHLjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 07:39:02 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1GAPZF-0003w4-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 09:16:13PM +1000, Herbert Xu wrote:
> Pekka Pietikainen <pp@ee.oulu.fi> wrote:
> > Only aironet lockdep related report I could find was 
> > http://marc.theaimsgroup.com/?l=linux-netdev&m=115406279721287&w=2
> > 
> > this looks a bit different:
> > 
> > Linux version 2.6.17-1.2528.fc6 (brewbuilder@hs20-bc2-2.build.redhat.com) (gcc version 4.1.1 20060802 (Red Hat 4.1.1-14)) #1 SMP Sun Aug 6 01:43:42 EDT 2006
> 
> If you run the latest upstream kernel this warning will disappear
> as different skb queues no have different lock keys.
Hmm... I retried with a 2.6.18rc4-based rawhide kernel and the warning
is still there, previous one was rc3-git7.

Could be http://marc.theaimsgroup.com/?l=linux-netdev&m=115461336523555&w=2
which isn't upstream yet, right?
