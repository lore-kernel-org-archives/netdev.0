From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] net: sctp: Move sequence start handling into
 sctp_transport_get_idx()
Date: Fri, 15 Jan 2016 17:05:32 -0200
Message-ID: <20160115190532.GH6074@mrl.redhat.com>
References: <1452865471-32509-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Xin Long <lucien.xin@gmail.com>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452865471-32509-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 15, 2016 at 02:44:31PM +0100, Geert Uytterhoeven wrote:
> net/sctp/proc.c: In function =E2=80=98sctp_transport_get_idx=E2=80=99=
:
> net/sctp/proc.c:313: warning: =E2=80=98obj=E2=80=99 may be used unini=
tialized in this function
>=20
> This is currently a false positive, as all callers check for a zero
> offset first, and handle this case in the exact same way.
>=20
> Move the check and handling into sctp_transport_get_idx() to kill the
> compiler warning, and avoid future bugs.
>=20
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
> Compile-tested only.

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
