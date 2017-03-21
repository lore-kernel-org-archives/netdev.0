From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] bridge: ebtables: fix reception of frames
 DNAT-ed to bridge device
Date: Tue, 21 Mar 2017 16:32:45 -0700
Message-ID: <20170321163245.34159349@xeon-e3>
References: <20170321222845.8373-1-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Linus =?UTF-8?B?TMO8c3Npbmc=?= <linus.luessing@c0d3.blue>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170321222845.8373-1-linus.luessing@c0d3.blue>
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

On Tue, 21 Mar 2017 23:28:45 +0100
Linus L=C3=BCssing <linus.luessing@c0d3.blue> wrote:

> However, the IP code drops it in the beginning of ip_input.c/ip_rcv()
> as the dnat target did not update the skb->pkt_type. If after
> dnat'ing the packet is now destined to us then the skb->pkt_type
> needs to be updated from PACKET_OTHERHOST to PACKET_HOST, too.

Why not fix DNAT netfilter module rather than hacking bridge code here.
