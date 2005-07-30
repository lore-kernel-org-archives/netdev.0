From: Sven Schuster <schuster.sven@gmx.de>
Subject: Re: [PATCH] add new nfnetlink_log subsystem
Date: Sat, 30 Jul 2005 18:41:21 +0200
Message-ID: <20050730164121.GA14794@zion.homelinux.com>
References: <20050730103005.GB6620@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SLDf9lqlvOQaIe6s"
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@gnumonks.org>, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline
In-Reply-To: <20050730103005.GB6620@rama.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hi Harald,

On Sat, Jul 30, 2005 at 12:30:05PM +0200, Harald Welte told us:
> diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
> new file mode 100644
> --- /dev/null
> +++ b/net/netfilter/nfnetlink_log.c
> @@ -0,0 +1,992 @@
=2E..
> +static struct sk_buff *nfulnl_alloc_skb(unsigned int inst_size,=20
> +					unsigned int pkt_size)
> +{
> +	struct sk_buff *skb;
> +
> +	UDEBUG("entered (%u, %u)\n", inst_size, pkt_size);
> +
> +	/* alloc skb whihc should be big enough for a whole multipart

typo, which

> +	 * message.  WARNING: has to be <=3D 128k due to slab restrictions */
> +

=2E..

> +
> +static int
> +init_or_cleanup(int init)
> +{

=2E..

> +#ifdef CONFIG_PROC_FS
> +	proc_nful =3D create_proc_entry("nfnetlink_log", 0440,
> +				      proc_net_netfilter);
> +	if (!proc_nful)
> +		goto cleanup_subsys;
> +	proc_nful->proc_fops =3D &nful_file_ops;
> +#endif
> +
> +	return status;
> +
> +cleanup:
> +	nf_log_unregister_logger(&nfulnl_logger);
> +#ifdef CONFIG_PROC_FS
> +cleanup_subsys:

no remove_proc_entry??

> +#endif
> +	nfnetlink_subsys_unregister(&nfulnl_subsys);
> +cleanup_netlink_notifier:
> +	netlink_unregister_notifier(&nfulnl_rtnl_notifier);
> +	return status;
> +}
> +

Kind regards,

Sven

--=20
Linux zion 2.6.13-rc3-mm1 #17 PREEMPT Thu Jul 28 02:56:37 CEST 2005 i686 at=
hlon i386 GNU/Linux
 18:34:22 up 19:35,  2 users,  load average: 0.28, 0.11, 0.03

--SLDf9lqlvOQaIe6s
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFC662xo4FAdB2PneQRAhSeAJ9AXhq/DxVoOM01A1MXBJ6zu5XJKACeKqvJ
f5e4LMz3lLvlImKOrq1NtBE=
=6deh
-----END PGP SIGNATURE-----

--SLDf9lqlvOQaIe6s--
