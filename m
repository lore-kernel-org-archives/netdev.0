From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: report congestion
 notification at enqueue time
Date: Fri, 29 Jun 2012 01:24:20 -0400
Message-ID: <CAA93jw7FmtbwFrAjZNnKyXc4H5dG=oa=jdqXg5Z7fSa=diOKtg@mail.gmail.com>
References: <1340903237.13187.151.camel@edumazet-glaptop>
	<CAA93jw7agn2J6Hd7x22KWhENY5jqVjnk6uRr=3LJ5Anw7EgacQ@mail.gmail.com>
	<1340907151.13187.169.camel@edumazet-glaptop>
	<CAK6E8=dM0HNjjT=pDWzkBHs2Npi9foAnk1zxXdVLqBxA63dSqw@mail.gmail.com>
	<CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	<1340945457.29822.7.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Nandita Dukkipati <nanditad@google.com>, netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>, codel@lists.bufferbloat.net,
	Matt Mathis <mattmathis@google.com>, Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1340945457.29822.7.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On Fri, Jun 29, 2012 at 12:50 AM, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:

> A router will have no use of this feature, not sure you need to spend
> time trying this ;)

It's not yer ordinary router...

A cerowrt router has iperf, netperf/netserver from svn with congestion
control switching and classification setting, rsync (with same),
samba, transmission, a polipo proxy, scamper, and a legion of other
network analysis tools on-board and available as optional packages.

and it's used in the bufferbloat project as a thoroughly understood
platform for originating, receiving, AND routing packets on a real
embedded home gateway platform that end users actually use, through a
decent set of drivers, on ethernet and wifi.

I am always concerned when changes to the stack like
GSO/GRO/BQL/fq_codel go into linux - or things like the infinite
window in ECN bug from a few months back happen - as they hold promise
to mutate (or explain) the statistics and analysis we've accumulated
over the last year and a half.

And as I'm hoping to do a major test run shortly to get some fresh
statistics vs a vs fq_codel vs the old sfqred tests ( I'm looking
forward to redoing this one in particular:
http://www.teklibre.com/~d/bloat/hoqvssfqred.ps - )

... and you are about to change what those stats are going to look
like, under load, with this change... I kind of need to
understand/track it/parse it/capture it. I've got sufficient hardware
now to easily A/B things.

(sorry for the noise on the lists)


-- =

Dave T=E4ht
