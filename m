From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCHv2 net-next 0/4] bridge: multicast snooping patches
	/ exports
Date: Sun, 25 May 2014 07:03:21 +0200
Message-ID: <1400994205-31165-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: b.a.t.m.a.n@lists.open-mesh.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
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

Changes in v2:

* fix a nasty typo in PATCH 1/4, br_multicast_update_query_timer():
  "br->multicast_query_interval" vs. "br->multicast_querier_interval"
  =3D> this accidentally reduced the other querier present timer=20
     from 255 to 125 seconds
* fix a typo in PATCH 2/4, br_ip{4,6}_multicast_query():
  ntohs(ETH_P_{IP,IPV6}) vs. htons(ETH_P_{IP,IPV6})
* add missing ntohl()s before address comparison in PATCH 2/4,
  br_ip4_multicast_select_querier() (thanks David!)

Cheers, Linus
