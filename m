From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Advice needed on IP-over-InfiniBand driver
Date: Thu, 30 Sep 2004 14:21:20 -0700
Sender: openib-general-bounces@openib.org
Message-ID: <OF16B04F62.A5B7B967-ON88256F1F.0074FAB1-88256F1F.00754741@us.ibm.com>
References: <521xgj1tx8.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
In-Reply-To: <521xgj1tx8.fsf@topspin.com>
To: Roland Dreier <roland@topspin.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

> However, it seems that broadcast ARP packets have skb->dst == NULL.
> Is it safe for me to assume that packets with skb->dst == NULL are
> broadcast packets?  Will multicast packets have a non-NULL dst?

I think it would be a mistake to use skb->dst as a flag for unicast
or not. Even if it is correct in all cases you care about now (I don't
know either way), it would be a hidden dependency with high potential
to break something eventually.

                                                +-DLS
