From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] openvswitch: Add missing initialization in
 validate_and_copy_set_tun()
Date: Wed, 11 Feb 2015 15:57:38 +0000
Message-ID: <20150211155738.GB29155@casper.infradead.org>
References: <1423650218-24666-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>, netdev@vger.kernel.org,
	dev@openvswitch.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1423650218-24666-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/11/15 at 11:23am, Geert Uytterhoeven wrote:
> net/openvswitch/flow_netlink.c: In function =E2=80=98validate_and_cop=
y_set_tun=E2=80=99:
> net/openvswitch/flow_netlink.c:1749: warning: =E2=80=98err=E2=80=99 m=
ay be used uninitialized in this function
>=20
> If ipv4_tun_from_nlattr() returns a different positive value than
> OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS, err will be uninitialized, and
> validate_and_copy_set_tun() may return an undefined value instead of =
a
> zero success indicator. Initialize err to zero to fix this.
>=20
> Fixes: 1dd144cf5b4b47e1 ("openvswitch: Support VXLAN Group Policy ext=
ension")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Acked-by: Thomas Graf <tgraf@suug.ch>
