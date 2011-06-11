From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bonding: restore NETIF_F_VLAN_CHALLENGED properly
 in bond_del_vlan()
Date: Sat, 11 Jun 2011 16:13:48 -0700 (PDT)
Message-ID: <20110611.161348.2031043829927945088.davem@davemloft.net>
References: <20110603201424.GB24804@midget.suse.cz>
	<28701.1307147211@death>
	<20110610202720.GA4256@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	pedro.netdev@dondevamos.com, kaber@trash.net,
	mirq-linux@rere.qmqm.pl
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41788 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715Ab1FKXRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 19:17:37 -0400
In-Reply-To: <20110610202720.GA4256@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Fri, 10 Jun 2011 22:27:20 +0200

> bonding: clean up bond_del_vlan()
> 
> 1) the setting of NETIF_F_VLAN_CHALLENGED in bond_del_vlan() is
> useless since commit b2a103e6 because bond_fix_features() now
> sets NETIF_F_VLAN_CHALLENGED whenever the last slave is being
> removed.
> 
> 2) the code never triggers anyway as vlan_list is never empty
> since ad1afb00.
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Applied, thanks.
