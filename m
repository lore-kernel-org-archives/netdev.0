From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Mon, 09 Jan 2017 09:05:49 +0100
Message-ID: <1483949149.17582.1.camel@sipsolutions.net>
References: <20170102193214.31723-1-linus.luessing@c0d3.blue>
	<1483706872.4089.8.camel@sipsolutions.net>
	<20170107151530.GG3134@otheros>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Braun <michael-dev@fami-braun.de>,
	"David S . Miller" <davem@davemloft.net>, Felix Fietkau <nbd@nbd.name>
To: Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170107151530.GG3134@otheros>
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

On Sat, 2017-01-07 at 16:15 +0100, Linus Lüssing wrote:

> Actually, I do not quite understand that remark in the mac80211
> multicast-to-unicast patch. IP should not care about the ethernet
> header?

But it does, for example RFC 1122 states:

         When a host sends a datagram to a link-layer broadcast address,
         the IP destination address MUST be a legal IP broadcast or IP
         multicast address.

         A host SHOULD silently discard a datagram that is received via
         a link-layer broadcast (see Section 2.4) but does not specify
         an IP multicast or broadcast destination address.

You can probably find other examples too.

johannes
