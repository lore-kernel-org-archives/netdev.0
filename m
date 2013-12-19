From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v3 8/8] drivers: net: Mark function
 xenvif_count_frag_slots() as static in netback.c
Date: Thu, 19 Dec 2013 11:48:58 +0000
Message-ID: <20131219114857.GI25969@zion.uk.xensource.com>
References: <04fe932bc3585620c91d511bb0894e45bb762ffa.1387382457.git.rashika.kheria@gmail.com>
 <72d6fe114ba7cc2f09f51e279313860f83142d46.1387382457.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <josh@joshtriplett.org>
To: Rashika Kheria <rashika.kheria@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <72d6fe114ba7cc2f09f51e279313860f83142d46.1387382457.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 19, 2013 at 02:26:47PM +0530, Rashika Kheria wrote:
> This patch marks the function xenvif_count_frag_slots() in netback.c =
as
> static because they are not used outside this file.
>=20
> Thus, it also removes the following warning in xen-netback/netback.c:
> drivers/net/xen-netback/netback.c:218:14: warning: no previous protot=
ype for =E2=80=98xenvif_count_frag_slots=E2=80=99 [-Wmissing-prototypes=
]
>=20
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Easy, there's no need to resend the patch with maintainer's Acked-by.
DaveM will take care of this. Just be patient. :-)

Wei.
