From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 3/3] bonding,ipv4,ipv6,vlan: Handle
 NETDEV_BONDING_FAILOVER like NETDEV_NOTIFY_PEERS
Date: Thu, 21 Apr 2011 21:13:49 -0700 (PDT)
Message-ID: <20110421.211349.193726731.davem@davemloft.net>
References: <22334.1302913805@death>
	<1303153792.2857.32.camel@bwh-desktop>
	<26398.1303240321@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, andy@greyhouse.net, kaber@trash.net,
	netdev@vger.kernel.org, brian.haley@hp.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53804
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750775Ab1DVEOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 00:14:23 -0400
In-Reply-To: <26398.1303240321@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Tue, 19 Apr 2011 12:12:01 -0700

> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
>>Why would we activate a slave without link up?  Perhaps if the previous
>>active slave is removed?
> 
> 	It's special sauce for Infiniband; I don't recall the details
> except that the submitter said that without it the initial gratuitous
> ARP could be lost.  I didn't (and still don't) have IB hardware to test
> this on.

I vaguely remember this IB has too, but also forget the details.

If someone would get to the bottom of this and add a nice big comment
to the code, to prevent such difficulties in remembering exactly why we
do this in the future, I would very much appreciate it.
