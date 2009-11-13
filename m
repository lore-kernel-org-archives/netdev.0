From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] bonding: fix 802.3ad standards compliance
 error
Date: Fri, 13 Nov 2009 15:30:58 -0800
Message-ID: <20091113153058.4b739ea3@nehalam>
References: <3048.1258153981@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	martin@gear6.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57574 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932252AbZKMXbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:31:04 -0500
In-Reply-To: <3048.1258153981@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2009 15:13:01 -0800
Jay Vosburgh <fubar@us.ibm.com> wrote:

> +	// check if all parameters are alike
> +	if (((ntohs(lacpdu->partner_port) == port->actor_port_number) &&
> +	     (ntohs(lacpdu->partner_port_priority) == port->actor_port_priority) &&
> +	     !MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) &&
> +	     (ntohs(lacpdu->partner_system_priority) == port->actor_system_priority) &&
> +	     (ntohs(lacpdu->partner_key) == port->actor_oper_port_key) &&
> +	     ((lacpdu->partner_state & AD_STATE_AGGREGATION) == (port->actor_oper_port_state & AD_STATE_AGGREGATION))) ||
> +	    // or this is individual link(aggregation == FALSE)

I know the code here doesn't follow kernel style, but please don't
add more C99 comments or overly long lines.

-- 
