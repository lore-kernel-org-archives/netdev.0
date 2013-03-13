From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH net-next v3] netxen: write IP address to firmware when
 using bonding
Date: Wed, 13 Mar 2013 11:51:46 +0000
Message-ID: <C562D0E12CBDE44E8A0CCAB7706009672C0F0F@AVMB1.qlogic.org>
References: <1363092541-12391-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"agospoda@redhat.com" <agospoda@redhat.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:39450
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755260Ab3CMLvw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 07:51:52 -0400
In-Reply-To: <1363092541-12391-1-git-send-email-nikolay@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----Original Message-----
>From: Nikolay Aleksandrov [mailto:nikolay@redhat.com]
>Sent: Tuesday, March 12, 2013 6:19 PM
>To: netdev
>Cc: Rajesh Borundia; David Miller; agospoda@redhat.com; Sony Chacko
>Subject: [PATCH net-next v3] netxen: write IP address to firmware when
>using bonding
>
>This patch allows LRO aggregation on bonded devices that contain an
>NX3031 device. It also adds a for_each_netdev_in_bond_rcu(bond, slave)
>macro which executes for each slave that has bond as master.
>
>V3: After testing and discussing this with Rajesh, I decided to keep the
>    vlan ip cache and just rename it to ip_cache since it will store
>bond
>    ip addresses too. A new master flag has been added to the ip cache
>to
>    denote that the address has been added because of a master device.
>    I've taken care of the enslave/release cases by checking for various
>    combinations of events and flags (e.g. netxen has a master, it's a
>    bond master and it's not marked as a slave means it is being
>enslaved
>    and is dev_open()ed in bond_enslave).
>    I've changed netxen_free_ip_list() to have a "master" parameter
>which
>    causes all IP addresses marked as master to be deleted (used when a
>    netxen is being released). I've made the patch use the new upper
>    device API as well. The following cases were tested:
>    - bond -> netxen
>    - vlan -> netxen
>    - vlan -> bond -> netxen

Acked-by : Rajesh Borundia <rajesh.borundia@qlogic.com>
