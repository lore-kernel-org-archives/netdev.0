From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH v2 net-next 6/6] bonding: remove unused bond->vlan_list
Date: Fri, 09 Aug 2013 13:44:10 +0200
Message-ID: <5204D60A.7080801@redhat.com>
References: <1375981079-2936-1-git-send-email-vfalico@redhat.com> <1375981079-2936-7-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8648 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965439Ab3HILs4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 07:48:56 -0400
In-Reply-To: <1375981079-2936-7-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2013 06:57 PM, Veaceslav Falico wrote:
> RFC -> v1: No changes.
> v1  -> v2: No changes.
> 
> There are currently no users of bond->vlan_list (other than the maintaining
> functions add/remove) - so remove it and every unneeded helper.
> 
> In this patch we remove:
> vlan_list from struct bonding
> bond_next_vlan - we don't need it anymore
> struct vlan_entry - it was a helper struct for bond->vlan_list
> some bits from bond_vlan_rx_add/kill_vid() - which were related to
> 	bond->vlan_list
> (de)initialization of vlan_list from bond_setup/uninit
> bond_add_vlan - its only scope was to maintain bond->vlan_list
> 
> We don't fully remove bond_del_vlan() - bond_alb_clear_vlan() still needs
> to be called when a vlan disappears. And we make bond_del_vlan() to not
> return anything cause it cannot fail already.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---

Very much
Acked-by: Nikolay Aleksandrov <nikolay@redhat.com>
