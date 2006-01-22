From: Denis Vlasenko <vda-BN/BzeNzsW2SlH3FCl+8hg@public.gmane.org>
Subject: Re: [PATCH] ieee80211_rx_any: filter out packets, call ieee80211_rx or ieee80211_rx_mgt
Date: Sun, 22 Jan 2006 14:08:45 +0200
Message-ID: <200601221408.45486.vda@ilport.com.ua>
References: <20060118200616.GC6583@tuxdriver.com> <200601221359.31482.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbenc-AlSwsSmVLrQ@public.gmane.org,
   softmac-dev-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
In-Reply-To: <200601221359.31482.vda-BN/BzeNzsW2SlH3FCl+8hg@public.gmane.org>
Content-Disposition: inline
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

On Sunday 22 January 2006 13:59, Denis Vlasenko wrote:
> bcm43xx_rx() contains code to filter out packets from
> foreign BSSes and decide whether to call ieee80211_rx
> or ieee80211_rx_mgt. This is not bcm specific.
>=20
> Patch adapts that code and adds it to softmac
> as ieee80211_rx_any() function.
>=20
> Diffed against wireless-2.6.git
>=20
> Signed-off-by: Denis Vlasenko <vda-BN/BzeNzsW2SlH3FCl+8hg@public.gmane.org>
> --
> vda

Please ignore this one. This is not good:

+=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Areturn ieee80211_rx_mgt(iee=
e, hdr, stats);

Use corrected patch in my another email with
"Date: Sun, 22 Jan 2006 14:04:52 +0200"
--
vda
