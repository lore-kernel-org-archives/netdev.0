From: =?iso-8859-1?Q?Dennis_J=F8rgensen?= <q@kampsax.dtu.dk>
Subject: Re: Trivial fix for wrong error message from icmp.c (2.6.0-test4)
Date: Sat, 6 Sep 2003 14:30:27 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33L0.0309061426200.2651-100000@carlsberg.kampsax.dtu.dk>
References: <20030905024736.4acefe68.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030905024736.4acefe68.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Fri, 5 Sep 2003, David S. Miller wrote:

> On Thu, 04 Sep 2003 02:26:42 +0200
> Dennis J=F8rgensen <postmaster@q.nospam.kampsax.k-net.dk> wrote:
>
> > Should I post this somewhere else/to someone else, please let me know=
, I
> > couldn't find a FAQ for the list.
>
> You're posting it to the correct place, but your patch does not
> apply because your mail client has turned all the tabs in the
> patch into spaces.

That wasn't very nice of it.

> I can't apply this patch until you fix that up.

It should be better now.

Sorry for the inconvenience.


  Dennis J=F8rgensen


--- linux-2.6.0-test4.org/net/ipv4/icmp.c	2003-08-28 01:13:59.000000000 +=
0200
+++ linux-2.6.0-test4/net/ipv4/icmp.c	2003-08-28 02:12:56.000000000 +0200
@@ -661,7 +661,7 @@
 			printk(KERN_WARNING "%u.%u.%u.%u sent an invalid ICMP "
 					    "type %u, code %u "
 					    "error to a broadcast: %u.%u.%u.%u on %s\n",
-			       NIPQUAD(iph->saddr),
+			       NIPQUAD(skb->nh.iph->saddr),
 			       icmph->type, icmph->code,
 			       NIPQUAD(iph->daddr),
 			       skb->dev->name);
