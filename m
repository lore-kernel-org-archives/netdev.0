From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 0/2] Exporting IGMP/MLD checking
 from bridge code
Date: Mon, 04 May 2015 14:49:44 -0400 (EDT)
Message-ID: <20150504.144944.1896578946813579544.davem@davemloft.net>
References: <1430568067-6912-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: bridge@lists.linux-foundation.org, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org, linux-kernel@vger.kernel.org,
	tom@herbertland.com
To: linus.luessing@c0d3.blue
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1430568067-6912-1-git-send-email-linus.luessing@c0d3.blue>
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

From: Linus L=FCssing <linus.luessing@c0d3.blue>
Date: Sat,  2 May 2015 14:01:05 +0200

> The multicast optimizations in batman-adv are yet only usable and
> enabled in non-bridged scenarios. To be able to support bridged setup=
s
> batman-adv needs to be able to detect IGMP/MLD queriers and reports o=
n
> mesh nodes without bridges, too. See the following link for details:
> =

> http://www.open-mesh.org/projects/batman-adv/wiki/Multicast-optimizat=
ions-listener-reports
> =

> To avoid duplicate code between the bridge and batman-adv, the IGMP/M=
LD
> message validation code is moved from the bridge to the IPv4/IPv6 sta=
ck.
> =

> On the way, some refactoring to increase readability and to iron out
> some subtle differences between the IGMP and MLD parsing code is done=
.=


Series applied, thanks.
