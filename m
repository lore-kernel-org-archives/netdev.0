From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH] net/nfc: Fix the compilation warning
Date: Mon, 30 Apr 2012 11:15:36 +0200
Message-ID: <20120430091536.GB31528@sortiz-mobl>
References: <1335771795-18961-1-git-send-email-josephdanielwalter@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joseph daniel <josephdanielwalter@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1335771795-18961-1-git-send-email-josephdanielwalter@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joseph,

On Mon, Apr 30, 2012 at 01:43:15PM +0600, joseph daniel wrote:
> the nfc_llcp_general_bytes is defined in nfc/core.c as
>     static inline u8 *nfc_llcp_general_bytes(struct nfc_dev *dev, siz=
e_t *gb_len).
>=20
> as in nfc/nfc.h:
>     static inline u8 *nfc_llcp_general_bytes(struct nfc_dev *dev, u8 =
*gb_len), as
>     CONFIG_NFC_LLCP is not defined.
>=20
> so we got some warnings,
> net/nfc/core.c:207:2: warning: passing argument 2 of =E2=80=98nfc_llc=
p_general_bytes=E2=80=99 from incompatible pointer type [enabled by def=
ault]
> net/nfc/nfc.h:87:19: note: expected =E2=80=98u8 *=E2=80=99 but argume=
nt is of type =E2=80=98size_t *=E2=80=99
>=20
> Signed-off-by: joseph daniel <josephdanielwalter@gmail.com>
Thanks, patch applied to my nfc-next branch.

Cheers,
Samuel.

--=20
Intel Open Source Technology Centre
http://oss.intel.com/
