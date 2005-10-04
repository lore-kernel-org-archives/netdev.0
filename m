From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ipv4/fib_frontend.c: (Re)export
	ip_dev_find for 2.6.14
Date: Tue, 04 Oct 2005 12:39:05 -0700 (PDT)
Message-ID: <20051004.123905.56817889.davem@davemloft.net>
References: <1128438073.4397.4105.camel@hal.voltaire.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: halr@voltaire.com
In-Reply-To: <1128438073.4397.4105.camel@hal.voltaire.com>
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

From: Hal Rosenstock <halr@voltaire.com>
Date: 04 Oct 2005 11:01:14 -0400

> (There is emerging functionality (not yet pushed upstream) in the IB
> subsystem which relies on this being available. ip_dev_find is used to
> find a valid IPoIB device when the outgoing device returned by the route
> lookup (ip_route_output_key) is using the loopback interface. A valid
> IPoIB device is needed to perform sending an ARP and doing an IB path
> lookup so that an IB connection can be made).

Then add this when this "emerging functionality" is pushed upstream.
