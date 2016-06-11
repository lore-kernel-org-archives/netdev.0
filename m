From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: Add ability to have GRE ignore DF
 bit in IPv4 payloads
Date: Fri, 10 Jun 2016 23:02:02 -0700 (PDT)
Message-ID: <20160610.230202.897629473050684544.davem@davemloft.net>
References: <20160607194846.11494-1-philipp@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: philipp@redfish-solutions.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35102 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbcFKGCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 02:02:04 -0400
In-Reply-To: <20160607194846.11494-1-philipp@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Philip Prindeville" <philipp@redfish-solutions.com>
Date: Tue,  7 Jun 2016 13:48:46 -0600

> From: Philip Prindeville <philipp@redfish-solutions.com>
> 
> In the presence of firewalls which improperly block ICMP Unreachable
> (including Fragmentation Required) messages, Path MTU Discovery is
> prevented from working.
> 
> A workaround is to handle IPv4 payloads opaquely, ignoring the DF bit--as
> is done for other payloads like AppleTalk--and doing transparent
> fragmentation and reassembly.
> 
> Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>

I think the feedback that this feature should be mutually exclusive
to pmtudisc is valid and you should address that.
