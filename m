From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Sun, 15 Sep 2002 21:23:21 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020915.212321.64867280.davem@redhat.com>
References: <20020913.150439.27187393.davem@redhat.com>
	<Pine.GSO.4.30.0209151053530.22001-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, todd-lkml@osogrande.com,
   tcw@tempest.prismnet.com, netdev@oss.sgi.com, pfeather@cs.unm.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <Pine.GSO.4.30.0209151053530.22001-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: jamal <hadi@cyberus.ca>
   Date: Sun, 15 Sep 2002 16:16:13 -0400 (EDT)

   Your proposal does make sense although compute power would still be
   a player. I think the key would be parallelization;

Oh I forgot to mention that some of these cards also compute a cookie
for you on receive packets, and your meant to point the input
processing for that packet to a cpu whose number is derived from that
cookie it gives you.

Lockless per-cpu packet input queues make this sort of hard for us
to implement currently.
