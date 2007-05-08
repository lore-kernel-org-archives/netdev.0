From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] ehea: Receive SKB Aggregation
Date: Tue, 8 May 2007 22:44:59 +1000
Message-ID: <20070508224459.7a46e1e4.sfr@canb.auug.org.au>
References: <200705081405.33742.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__8_May_2007_22_44_59_+1000_2D.TR.V1=VgSWO2="
Cc: Jeff Garzik <jeff@garzik.org>, Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>
To: Thomas Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:37831 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934673AbXEHMpE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 08:45:04 -0400
In-Reply-To: <200705081405.33742.osstklei@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__8_May_2007_22_44_59_+1000_2D.TR.V1=VgSWO2=
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

On Tue, 8 May 2007 14:05:33 +0200 Thomas Klein <osstklei@de.ibm.com> wrote:
>
> +struct ehea_lro {
> +	struct sk_buff *parent;
> +	struct sk_buff *last_skb;
> +        struct iphdr *iph;
> +        struct tcphdr *tcph;
   ^^^^^^^^
Spaces instead of tabs.

Also in at least one other place in this patch.

--
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__8_May_2007_22_44_59_+1000_2D.TR.V1=VgSWO2=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFGQHDRFdBgD/zoJvwRAjwxAJ9UTT3P1RuptBk7k8kJXiwDQ9g4/QCgjyrM
NRwkVc8qbfnHZoI31ZxMCo4=
=gY89
-----END PGP SIGNATURE-----

--Signature=_Tue__8_May_2007_22_44_59_+1000_2D.TR.V1=VgSWO2=--
