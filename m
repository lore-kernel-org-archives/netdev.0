From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] vxlan: Refactor vxlan_udp_encap_recv() to kill compiler
 warning
Date: Fri, 4 Sep 2015 17:00:02 +0200
Message-ID: <20150904150002.GA3113@pox.localdomain>
References: <1441363772-20850-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1441363772-20850-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/04/15 at 12:49pm, Geert Uytterhoeven wrote:
> drivers/net/vxlan.c: In function =E2=80=98vxlan_udp_encap_recv=E2=80=99=
:
> drivers/net/vxlan.c:1226: warning: =E2=80=98info=E2=80=99 may be used=
 uninitialized in this function
>=20
> While this warning is a false positive, it can be killed easily by
> getting rid of the pointer intermediary and referring directly to the
> ip_tunnel_info structure.
>=20
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Acked-by: Thomas Graf <tgraf@suug.ch>
