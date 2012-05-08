From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/25] ipvs: remove check for IP_VS_CONN_F_SYNC from
 ip_vs_bind_dest
Date: Mon, 07 May 2012 21:36:07 -0400 (EDT)
Message-ID: <20120507.213607.2054696052002528963.davem@davemloft.net>
References: <1336436539-5880-1-git-send-email-pablo@netfilter.org>
	<1336436539-5880-14-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1336436539-5880-14-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Tue,  8 May 2012 02:22:07 +0200

> +		/* It is a normal connection, so modify the counters
> +		 * according to the flags, later the protocol can
> +		 * update them on state change */

Rather:

		/* It is a normal connection, so modify the counters
		 * according to the flags, later the protocol can
		 * update them on state change
		 */
