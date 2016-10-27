From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for
 forwarded ICMP errors from offending packet
Date: Thu, 27 Oct 2016 11:25:25 -0400 (EDT)
Message-ID: <20161027.112525.2290598329610980726.davem@davemloft.net>
References: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
        <1477301332-23954-6-git-send-email-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: jkbs@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477301332-23954-6-git-send-email-jkbs@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Mon, 24 Oct 2016 11:28:52 +0200

> +	inner_iph = skb_header_pointer(
> +		skb, skb_transport_offset(skb) + sizeof(*icmph),
> +		sizeof(_inner_iph), &_inner_iph);

Please do not style this call like this, put as many arguments as
you can on the first line.

	inner_iph = skb_header_pointer(skb,
				       skb_transport_offset(skb) + sizeof(*icmph),
				       sizeof(_inner_iph), &_inner_iph);

And on the second and subsequent lines, indent to the first column after
the openning parenthesis of the first line.
