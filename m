From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Mon, 09 Jan 2017 16:47:01 +0100
Message-ID: <1483976821.20579.0.camel@sipsolutions.net>
References: <20170102193214.31723-1-linus.luessing@c0d3.blue>
	<1483706872.4089.8.camel@sipsolutions.net>
	<8836daaa-9638-4502-d079-fd428595f822@nbd.name>
	<1483710841.12677.1.camel@sipsolutions.net>
	<22fad045-57c6-7789-d19f-f47bd0faf441@fami-braun.de>
	<20170107145516.GE3134@otheros>
	<1483949336.17582.3.camel@sipsolutions.net>
	<6f5ec9f1-800a-2bc4-2f41-9d803343bb22@fami-braun.de>
	<1483964159.17582.34.camel@sipsolutions.net>
	<ebc5050e12c04273fa518e35d7f0b8bc@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>, Felix Fietkau <nbd@nbd.name>
To: michael-dev <michael-dev@fami-braun.de>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <ebc5050e12c04273fa518e35d7f0b8bc@fami-braun.de>
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

On Mon, 2017-01-09 at 16:25 +0100, michael-dev wrote:
> Am 09.01.2017 13:15, schrieb Johannes Berg:
> > > That is bridge fdb entries (need to) expire so the bridge might
> > > "forget" a still-connected station not sending but only consuming
> > > broadcast traffic.
> > 
> > Ok, that I don't know. Somehow if you address a unicast packet
> > there
> > the bridge has to make a decision - so it really should know?
> 
> If the bridge has not learned the unicast destination mac address on
> any port, it will flood the packet on all ports except the port it
> received the packet on.

Ok, so this really needs to be done in mac80211.

I'll send out the pull request soon then.

johannes
