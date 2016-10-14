From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/2] lwtunnel: Add destroy state operation
Date: Fri, 14 Oct 2016 10:59:47 +0200
Message-ID: <20161014105948.2a53c2cd@griffin>
References: <20161014005743.288956-1-tom@herbertland.com>
        <20161014005743.288956-2-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <roopa@cumulusnetworks.com>, <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59742 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751246AbcJNI7x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 04:59:53 -0400
In-Reply-To: <20161014005743.288956-2-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Oct 2016 17:57:42 -0700, Tom Herbert wrote:
> @@ -43,13 +44,11 @@ struct lwtunnel_encap_ops {
>  	int (*get_encap_size)(struct lwtunnel_state *lwtstate);
>  	int (*cmp_encap)(struct lwtunnel_state *a, struct lwtunnel_state *b);
>  	int (*xmit)(struct sk_buff *skb);
> +	void (*destroy_state)(struct lwtunnel_state *lws);
>  };

Could you add destroy_state next to build_state? Seems weird to have
those two scattered at the opposite ends of the structure. Looks good
otherwise.

Thanks,

 Jiri
