From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] [SCTP]: Remove sctp_add_cmd_sf wrapper bloat
Date: Thu, 27 Mar 2008 17:54:37 -0700 (PDT)
Message-ID: <20080327.175437.98682881.davem@davemloft.net>
References: <1206621486-5408-6-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1206621486-5408-7-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1206621486-5408-8-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, acme@redhat.com,
	vladislav.yasevich@hp.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757426AbYC1Ayx@vger.kernel.org>
In-Reply-To: <1206621486-5408-8-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 27 Mar 2008 14:38:06 +0200

> With a was number of callsites sctp_add_cmd_sf wrapper bloats
> kernel by some amount. Due to unlikely tracking allyesconfig,
> with the initial result were around ~7kB (thus caught my
> attention) while a non-debug config produced only ~2.3kB effect.
>=20
> I (ij) proposed first a patch to uninline it but Vlad responded
> with a patch that removed the only sctp_add_cmd call which is
> wrapped by sctp_add_cmd_sf (I wasn't sure if I could do that).
> I did minor cleanup to Vlad's patch.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, thanks.
