From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] net: Move destructor from neigh->ops
	to neigh_params
Date: Mon, 6 Mar 2006 21:16:30 -0800
Message-ID: <20060306211630.0df79464.akpm@osdl.org>
References: <adazmlmmy7v.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <adazmlmmy7v.fsf@cisco.com>
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

Roland Dreier <rdreier@cisco.com> wrote:
>
> struct neigh_ops currently has a destructor field, which no in-kernel
>  drivers outside of infiniband use.

net/atm/clip.c begs to disagree.

I'm also wondering why a combination of the net and infiniband trees does this:

drivers/infiniband/ulp/ipoib/ipoib_multicast.c: In function `ipoib_mcast_free':
drivers/infiniband/ulp/ipoib/ipoib_multicast.c:118: error: structure has no member named `destructor'
