From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: sk_dst_cache RCUification
Date: Wed, 14 Apr 2010 07:47:42 +0200
Message-ID: <1271224062.16881.605.camel@edumazet-laptop>
References: <1270803809.2623.69.camel@edumazet-laptop>
	 <20100413.015232.67916764.davem@davemloft.net>
	 <1271199845.16881.586.camel@edumazet-laptop>
	 <20100413.161153.135265420.davem@davemloft.net>
	 <1271223325.16881.600.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:62117 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab0DNFrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 01:47:48 -0400
Received: by bwz19 with SMTP id 19so6888bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 22:47:46 -0700 (PDT)
In-Reply-To: <1271223325.16881.600.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 avril 2010 =C3=A0 07:35 +0200, Eric Dumazet a =C3=A9crit=
 :
> Le mardi 13 avril 2010 =C3=A0 16:11 -0700, David Miller a =C3=A9crit =
:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, 14 Apr 2010 01:04:05 +0200
> >=20
> > > Instead of using rcu on whole "struct socket", my plan is to use =
a small
> > > structure :
> > >=20
> > > struct wait_queue_head_rcu {
> > > 	wait_queue_head_t wait;
> > > 	struct rcu_head	  rcu;
> > > } ____cacheline_aligned_in_smp;
> > >=20
> > > and make sk->sk_sleep points to this 'wait' field.
> >=20
> > So you're relying upon the fact that in the non-FASYNC case
> > the struct socket's wait queue is never actually used?
>=20
> Yes, for the first phase of my work, by asynch handling might be RCUf=
ied
> too in a second phase :)

Oh well, I did not really understood the question David, please ignore
the answer (I need to fully wake before...)



