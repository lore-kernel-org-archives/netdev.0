From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [netfilter-core] Re: [Patch]: IPv6 Connection Tracking
Date: Thu, 25 Sep 2003 12:50:51 +0200 (CEST)
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <Pine.LNX.4.33.0309251242380.27573-100000@blackhole.kfki.hu>
References: <20030925092806.GC5758@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>,
	<coreteam@netfilter.org>, <netfilter-devel@lists.netfilter.org>,
	<netdev@oss.sgi.com>, <usagi-core@linux-ipv6.org>
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20030925092806.GC5758@sunbeam.de.gnumonks.org>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Thu, 25 Sep 2003, Harald Welte wrote:

> However, we are now facing the problem on how we want to proceed.

I completely agree with Harald and does not like the idea of adding
(more) duplicated code to the system. There are already too much
duplication between IPv4/IPv6 at netfilter level, which must be sorted
out.

> 1) submit ip6_conntrack to the 2.6.x kernel
>    We would then need somebody committe to maintaining it, assuring
>    it keeps in sync with the work done on ip_conntrack.  I do not want
>    to put the burden of ip_conntrack / ip6_conntrack synchronization on
>    everybody who submits patches/bugfixes/...
>
> 2) keep ip6_conntrack in patch-o-matic and start work on a l3
>    independent conntrack system.
>    This would give more users to the code, since most advanced
>    netfilter users are using patch-o-matic anyway.

Yes, let's go with the latter solution.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@sunserv.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
