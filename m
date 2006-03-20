From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: TSO and IPoIB performance degradation
Date: Mon, 20 Mar 2006 12:22:34 +0200
Message-ID: <20060320102234.GV29929@mellanox.co.il>
References: <4410C671.2050300@hp.com>
	<20060309.232301.77550306.davem@davemloft.net>
	<20060320090629.GA11352@mellanox.co.il>
	<20060320.015500.72136710.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rick.jones2@hp.com,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060320.015500.72136710.davem@davemloft.net>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Quoting r. David S. Miller <davem@davemloft.net>:
> The path an SKB can take is opaque and unknown until the very last
> moment it is actually given to the device transmit function.

Why, I was proposing looking at dst cache. If that's NULL, well,
we won't stretch ACKs. Worst case we apply the wrong optimization.
Right?

> People need to get the "special case this topology" ideas out of their
> heads. :-)

Okay, I get that.

What I'd like to clarify, however: rfc2581 explicitly states that in some cases
it might be OK to generate ACKs less frequently than every second full-sized
segment. Given Matt's measurements, TCP on top of IP over InfiniBand on Linux
seems to hit one of these cases.  Do you agree to that?

-- 
Michael S. Tsirkin
Staff Engineer, Mellanox Technologies
