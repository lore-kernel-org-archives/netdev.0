From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: allow non-netadmin to query settings
Date: Mon, 23 Aug 2010 20:44:31 -0700 (PDT)
Message-ID: <20100823.204431.267970668.davem@davemloft.net>
References: <20100823132418.7721b072@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54135
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753684Ab0HXDoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 23:44:14 -0400
In-Reply-To: <20100823132418.7721b072@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 23 Aug 2010 13:24:18 -0700

> The SNMP daemon uses ethtool to determine the speed of
> network interfaces. This fails on Debian (and probably elsewhere)
> because for security SNMP daemon runs as non-root user (snmp).
> 
> Note: A similar patch was rejected previously because of a concern about
> the possibility that on some hardware querying the ethtool settings
> requires access to the PHY and could slow the machine down.  But the
> security risk of requiring SNMP daemon (and related services)
> to run as root far out weighs the risk of denial-of-service.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
