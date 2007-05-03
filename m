From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] [IPV4] SNMP: Display new statistics at
 /proc/net/snmp
Date: Thu, 03 May 2007 03:15:46 -0700 (PDT)
Message-ID: <20070503.031546.83595703.davem@davemloft.net>
References: <20070427164630.3160ded5.mitch@linux.vnet.ibm.com>
	<20070430.005014.09663543.davem@davemloft.net>
	<20070502100513.033aecd7.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mitch@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45143
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031113AbXECKPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 06:15:45 -0400
In-Reply-To: <20070502100513.033aecd7.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Date: Wed, 2 May 2007 10:05:13 +0900

> [IPV4] SNMP: Display new statistics at /proc/net/netstat
> 
> This displays the statistics specified in the updated IP-MIB RFC
> (RFC4293) in /proc/net/netstat. The reason why these are not added
> to /proc/net/snmp is that some existing utilities are developed under
> the assumption that ipstat items in /proc/net/snmp is unchanged.
> 
> Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>

Magic constant "17" is not the best, somebody will break this
next time this table it touched.

Why not use another sentinel, or something like that, to mark
the entry groups?
