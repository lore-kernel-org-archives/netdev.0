From: Roland Dreier <roland@topspin.com>
Subject: Re: Advice needed on IP-over-InfiniBand driver
Date: Thu, 30 Sep 2004 14:48:53 -0700
Sender: openib-general-bounces@openib.org
Message-ID: <52sm8zxwai.fsf@topspin.com>
References: <OF16B04F62.A5B7B967-ON88256F1F.0074FAB1-88256F1F.00754741@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF16B04F62.A5B7B967-ON88256F1F.0074FAB1-88256F1F.00754741@us.ibm.com>
	(David Stevens's message of "Thu, 30 Sep 2004 14:21:20 -0700")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    David> I think it would be a mistake to use skb->dst as a flag for
    David> unicast or not. Even if it is correct in all cases you care
    David> about now (I don't know either way), it would be a hidden
    David> dependency with high potential to break something
    David> eventually.

That's kind of what I thought.  But since my packets have no L2 header
in them, I don't know what hard_start_xmit can look at other than
skb->dst.

I guess hard_header could put some info in skb->cb -- is cb available
for net device use between hard_header and hard_start_xmit, or does
someone else still own it?

Thanks,
  Roland
