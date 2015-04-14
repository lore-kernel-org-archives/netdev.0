From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCHv2 net-next 0/2] Exporting IGMP/MLD checking from
	bridge code
Date: Tue, 14 Apr 2015 08:37:40 +0200
Message-ID: <1428993462-6079-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <therbert@google.com>, "David S. Miller" <davem@davemloft.net>
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

The multicast optimizations in batman-adv are yet only usable and
enabled in non-bridged scenarios. To be able to support bridged setups
batman-adv needs to be able to detect IGMP/MLD queriers and reports on
mesh nodes without bridges, too. See the following link for details:

http://www.open-mesh.org/projects/batman-adv/wiki/Multicast-optimizations=
-listener-reports

To avoid duplicate code between the bridge and batman-adv, the IGMP/MLD
message validation code is moved from the bridge to the IPv4/IPv6 stack.

On the way, some refactoring to increase readability and to iron out
some subtle differences between the IGMP and MLD parsing code is done.

Cheers, Linus


Changelog v2:
* Updated copyright for mcast_snoop.c
