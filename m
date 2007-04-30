From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] [IPV4] SNMP: Display new statistics at
 /proc/net/snmp
Date: Mon, 30 Apr 2007 00:50:14 -0700 (PDT)
Message-ID: <20070430.005014.09663543.davem@davemloft.net>
References: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
	<20070417201436.ab8f3f7a.mitch@linux.vnet.ibm.com>
	<20070427164630.3160ded5.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mitch@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57667
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423142AbXD3HuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 03:50:17 -0400
In-Reply-To: <20070427164630.3160ded5.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Date: Fri, 27 Apr 2007 16:46:30 +0900

> On Tue, 17 Apr 2007 20:14:36 +0900
> Mitsuru Chinen <mitch@linux.vnet.ibm.com> wrote:
> 
> > This displays the statistics specified in the updated IP-MIB RFC
> > (RFC4293) at /proc/net/snmp. As new statistics are placed as the
> > last elements, this change wouldn't affect netstat, net-snmp, etc.
> 
> I'm sorry. I found adding new entries to /proc/net/snmp affects
> net-snmp. I'm ashamed of my inadequate investigation.
> 
> However the other patches to support new statistics will be useful.
> Could you pick up 1st to 5th patches?

You could display them on a new line of /proc/net/netstat, which
we currently use to display extensions to the TCP snmp variables.

It is just one idea.

Anyways, I applied patches 1-5.
