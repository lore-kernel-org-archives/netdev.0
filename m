From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCHv2 2/2] bridge: multicast: enable snooping on
	general queries only
Date: Mon, 10 Mar 2014 23:56:00 +0100
Message-ID: <20140310225600.GJ5493@order.stressinduktion.org>
References: <1394486725-4992-1-git-send-email-linus.luessing@web.de>
	<1394486725-4992-2-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jan Stancek <jstancek@redhat.com>
To: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1394486725-4992-2-git-send-email-linus.luessing@web.de>
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

On Mon, Mar 10, 2014 at 10:25:25PM +0100, Linus L=C3=BCssing wrote:
>  	br_multicast_query_received(br, port, &br->ip6_querier,
> -				    !ipv6_addr_any(&ip6h->saddr), max_delay);
> +				    !ipv6_addr_any(&ip6h->saddr),
> +				    is_general_query, max_delay);

Just a small nit, maybe for a later patch:

After your change 6565b9eeef194a ("bridge: multicast: add sanity check
for query source addresses"), which is still in -net only, we could
replace !ipv6_addr_any(&ip6h->saddr) with '1'?

Greetings,

  Hannes
