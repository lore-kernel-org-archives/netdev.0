From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH] tests: Remove bashisms (s/source/.)
Date: Fri, 13 Oct 2017 17:55:45 +0000
Message-ID: <C7ED1FFD-C1B2-4543-9DBD-B633E7D0AA30@intel.com>
References: <20171008143916.21813-1-petr.vorel@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
        boundary="Apple-Mail=_48F7F435-3A21-479C-B38C-CEC77E370B68";
        protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Petr Vorel <petr.vorel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59510 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751762AbdJMR4A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 13:56:00 -0400
In-Reply-To: <20171008143916.21813-1-petr.vorel@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_48F7F435-3A21-479C-B38C-CEC77E370B68
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Oct 8, 2017, at 7:39 AM, Petr Vorel <petr.vorel@gmail.com> wrote:
>=20
> diff --git a/testsuite/tests/ip/route/add_default_route.t =
b/testsuite/tests/ip/route/add_default_route.t
> index e5ea6473..0b566f1f 100755
> --- a/testsuite/tests/ip/route/add_default_route.t
> +++ b/testsuite/tests/ip/route/add_default_route.t
> @@ -1,6 +1,6 @@
> -#!/bin/sh
> +#!/bin/bash

Funny - ^^^ choosing bash explicitly while
   vvvv removing the bashism?

> -source lib/generic.sh
> +. lib/generic.sh
>=20
> ts_log "[Testing add default route]"

I noticed a couple other files already specified /bin/bash, yet you =
removed the bashisms. But the above struck me as something that would =
not seem to have been intended.
--Apple-Mail=_48F7F435-3A21-479C-B38C-CEC77E370B68--
