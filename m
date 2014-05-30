From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2 net-next 3/4] bridge: add export of multicast
 database adjacent to net_dev
Date: Fri, 30 May 2014 07:38:34 -0700
Message-ID: <20140530073834.0986af33@nehalam.linuxnetplumber.net>
References: <1400994205-31165-1-git-send-email-linus.luessing@web.de>
	<1400994205-31165-4-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org, "David S.
	Miller" <davem@davemloft.net>, b.a.t.m.a.n@lists.open-mesh.org,
	linux-kernel@vger.kernel.org
To: Linus =?ISO-8859-1?B?TPxzc2luZw==?= <linus.luessing@web.de>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1400994205-31165-4-git-send-email-linus.luessing@web.de>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sun, 25 May 2014 07:03:24 +0200
Linus L=FCssing <linus.luessing@web.de> wrote:

> With this new, exported function br_multicast_list_adjacent(net_dev) a
> list of IPv4/6 addresses is returned. This list contains all multicast
> addresses sensed by the bridge multicast snooping feature on all bridge
> ports of the bridge interface of net_dev, excluding addresses from the
> specified net_device itself.
>=20
> Adding bridge support to the batman-adv multicast optimization requires
> batman-adv knowing about the existence of bridged-in multicast
> listeners to be able to reliably serve them with multicast packets.
>=20
> Signed-off-by: Linus L=FCssing <linus.luessing@web.de>

Please use EXPORT_SYMBOL_GPL
