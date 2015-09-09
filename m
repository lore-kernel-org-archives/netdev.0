From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Wed, 9 Sep 2015 17:54:04 +0200
Message-ID: <20150909155404.GC19913@calimero.vinschen.de>
References: <55E9A518.3080906@gmail.com>
 <20150904.113657.2146226970417029162.davem@davemloft.net>
 <20150904205904.GA32346@electric-eye.fr.zoreil.com>
 <20150906101954.GE30539@calimero.vinschen.de>
 <55ED391C.2090906@gmail.com>
 <20150907085023.GA17511@calimero.vinschen.de>
 <55EDA281.3030706@gmail.com>
 <55EE81D8.4010008@gmail.com>
 <55F04F40.4040901@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="+nBD6E3TurpgldQp"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Mike Massonnet <m8t@gandi.net>,
	Benedikt Meurer <benedikt.meurer@unix-ag.uni-siegen.de>,
	Bernhard Walle <bernhard.walle@gmx.de>,
	Hendrik Scholz <hscholz@raisdorf.net>,
	Florian Rivoal <frivoal@xfce.org>
To: poma <pomidorabelisima@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:59894 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbbIIPyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 11:54:08 -0400
Content-Disposition: inline
In-Reply-To: <55F04F40.4040901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--+nBD6E3TurpgldQp
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Sep  9 17:24, poma wrote:
> [PATCH net] r8169: Fix sleeping function called during get_stats64
> http://marc.info/?l=linux-netdev&m=144180123410135&q=raw
> - the noise is still present

Are you really sure?  The entire dma_alloc/dma_free stuff has been moved
away.  There's no locking or sleeping involved different from what was
there before my original patch when calling .ndo_get_stats64.

How would I be able to reproduce this on the command line?


Corinna

--+nBD6E3TurpgldQp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV8FYcAAoJEPU2Bp2uRE+gqjgP/3hJQVKhJiR5F0UJKVJ6+SsV
Rn4bJVH69Qdb4fIrF6Uo5BST0TJS7X4XuPvzugU/pxKLE/w9h4yJ3lk/SkguCNCw
4pDaSnSKFxkBIF5iS4MdvIi+QN5AqgpsLtS2kdk1palULUSRwJE3A5eL4rSfvdu4
46bZbAQpCEGqVrTPVXt9ZEuJeOzJRqsBE2EGrisV4GE6DJls5VQEwEbQCUnvguyZ
MUZicXmgtkxX1D6cspfxs7R3rVAS1hJQxz1oaQO2IN45T6mAIl2brbYA2gDWedqH
zukdsTxSfaVb09/SsMybIjviyn0CreTaxtXydWfKJDDaxuspp6Zm3f/x4gktHCT/
0QcXyx/rX9rDDdpC3+EAoit3jpm+Dr+6L0oRqlaumnD/j8U0Mjhwh3nPuJtPdZGn
FVT4kRsKWnYWExi1CnmWe20rsFQ4YqOjB0xYshx75tdAdLwMJ35b6omi81hE9wE5
txWKGKq3/IiX8ufiDs+2Ru8VWb2Ut7rGQjUkwiezah2kWpe2QX34OqawYSvvvmT/
q3YOYbqkk66J0o05bEemjmhTpOQtrStGNliqCv740JuXtx4azumD9Qs+uJ/wQTQS
tkGi41DyTcALS8gKEgvYsVhyBPjFOneH0cIRe03SuUmeYUUA75qWnL3zlwXNvfAa
vZBlAtckeIbdh4dXjBMx
=tqVN
-----END PGP SIGNATURE-----

--+nBD6E3TurpgldQp--
