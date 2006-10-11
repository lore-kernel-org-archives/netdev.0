From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Tue, 10 Oct 2006 19:53:41 -0700 (PDT)
Message-ID: <20061010.195341.32721754.davem@davemloft.net>
References: <4522A88E.2070200@redhat.com>
	<20061004.000722.99203823.davem@davemloft.net>
	<452C4D12.9060102@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mgrondona@llnl.gov, behlendorf1@llnl.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48042
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932427AbWJKCxj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 22:53:39 -0400
To: woodard@redhat.com
In-Reply-To: <452C4D12.9060102@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Woodard <woodard@redhat.com>
Date: Tue, 10 Oct 2006 18:46:58 -0700

> @@ -257,6 +259,8 @@
>  	__u8	frto_counter;	/* Number of new acks after RTO */
>  	__u8	nonagle;	/* Disable Nagle algorithm?             */
>  	__u8	keepalive_probes; /* num of allowed keep alive probes	*/
> +        __u16   rto_max;        /* Maximum backoff value in ms          */
> +        __u16   rto_init;       /* Initial backoff value in ms          */

The existing struct members are properly indented using tabs,
your patch adds members which are indented using spaces.  Please
fix this, thanks a lot.
