From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] bonding: fix 802.3ad standards compliance error
Date: Fri, 13 Nov 2009 15:47:33 -0800
Message-ID: <6802.1258156053@death.nxdomain.ibm.com>
References: <3048.1258153981@death.nxdomain.ibm.com> <20091113153058.4b739ea3@nehalam>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	martin@gear6.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:39172 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932435AbZKMXrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 18:47:37 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e32.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nADNgT4J028367
	for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 16:42:29 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nADNlgEI181912
	for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 16:47:42 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nADNlgVv018904
	for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 16:47:42 -0700
In-reply-to: <20091113153058.4b739ea3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:

>On Fri, 13 Nov 2009 15:13:01 -0800
>Jay Vosburgh <fubar@us.ibm.com> wrote:
>
>> +	// check if all parameters are alike
>> +	if (((ntohs(lacpdu->partner_port) == port->actor_port_number) &&
>> +	     (ntohs(lacpdu->partner_port_priority) == port->actor_port_priority) &&
>> +	     !MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) &&
>> +	     (ntohs(lacpdu->partner_system_priority) == port->actor_system_priority) &&
>> +	     (ntohs(lacpdu->partner_key) == port->actor_oper_port_key) &&
>> +	     ((lacpdu->partner_state & AD_STATE_AGGREGATION) == (port->actor_oper_port_state & AD_STATE_AGGREGATION))) ||
>> +	    // or this is individual link(aggregation == FALSE)
>
>I know the code here doesn't follow kernel style, but please don't
>add more C99 comments or overly long lines.

	I didn't, really; I moved the function up in the file rather
than adding a forward declaration.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
