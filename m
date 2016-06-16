From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: ipv4: Add ability to have GRE ignore
 DF bit in IPv4 payloads
Date: Wed, 15 Jun 2016 21:40:23 -0700 (PDT)
Message-ID: <20160615.214023.311089359262499722.davem@davemloft.net>
References: <20160614215302.21641-1-philipp@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	alexander.duyck@gmail.com
To: philipp@redfish-solutions.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163AbcFPEkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 00:40:24 -0400
In-Reply-To: <20160614215302.21641-1-philipp@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Philip Prindeville" <philipp@redfish-solutions.com>
Date: Tue, 14 Jun 2016 15:53:02 -0600

> From: Philip Prindeville <philipp@redfish-solutions.com>
> 
>     In the presence of firewalls which improperly block ICMP Unreachable
>     (including Fragmentation Required) messages, Path MTU Discovery is
>     prevented from working.
>     
>     A workaround is to handle IPv4 payloads opaquely, ignoring the DF bit--as
>     is done for other payloads like AppleTalk--and doing transparent
>     fragmentation and reassembly.
>     
>     Redux includes the enforcement of mutual exclusion between this feature
>     and Path MTU Discovery as suggested by Alexander Duyck.
>     
>     Cc: Alexander Duyck <alexander.duyck@gmail.com>
>     Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
>     Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>

Applied.
