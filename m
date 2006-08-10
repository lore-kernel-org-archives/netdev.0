From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: bonding questions: "replaying" call to set_multicast_list and
 sending IGMP doing Fail-Over
Date: Thu, 10 Aug 2006 16:03:54 +0300
Message-ID: <44DB2EBA.9030809@voltaire.com>
References: <Pine.LNX.4.64.0608030815270.32510@zuben> <44D89A10.10701@voltaire.com> <200608081720.k78HKSZt020293@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:4110 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP
	id S1161247AbWHJND6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 09:03:58 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200608081720.k78HKSZt020293@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	I haven't studied the effects of having large amounts of
> multicast traffic coming in under this situation.
> 
> 	However, I would suspect that the MAC filters found on
> sufficiently modern network adapters would drop the incoming multicast
> traffic on the backup slaves, as only the active slave in active-backup
> mode has its multicast list set.  That information is sent to a slave
> when it becomes the active slave; see the call to bond_mc_swap() made by
> bond_change_active_slave().

OK, i agree the MAC filter would drop the incoming traffic on the backup 
slaves b/c bond_mc_swap() calls bond_mc_delete() on the slave which 
becomes a backup one. But as you have noted there might be some impact 
on the switch.

Or.

