From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] iptables CLUSTERIP target
Date: Wed, 20 Oct 2004 21:40:00 -0700
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20041020214000.22757cf9.davem@davemloft.net>
References: <20041020223828.GP19899@sunbeam.de.gnumonks.org>
	<20041021.081837.99226422.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: laforge@netfilter.org, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org,
	netfilter-devel@lists.netfilter.org, lmb@suse.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20041021.081837.99226422.yoshfuji@linux-ipv6.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004 08:18:37 +0900 (JST)
YOSHIFUJI Hideaki / =1B$B5HF#1QL@=1B(B <yoshfuji@linux-ipv6.org> wrote:

> In article <20041020223828.GP19899@sunbeam.de.gnumonks.org> (at Thu, 21 O=
ct 2004 00:38:28 +0200), Harald Welte <laforge@netfilter.org> says:
>=20
> > Apart from the usual netfilter-specific file additions and
> > Kconfig/Makefile patches, this needs to export proc_file_operations in
> > order to get the reference counting of certain data objects right.  I
> > hope this change is acceptable.
>=20
> Please use seq_file instead.  Thanks.

Also, if not, we need to get upstream approval for exporting
proc_file_operations.

Harald, if it is not possible to use seq_file here for some
reason, please post the proc_file_operations exporting patch
(with a suitable description of course) to linux-kernel

Meanwhile this patch is on hold until this is resolved.

Thanks.
