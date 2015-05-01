From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] r8169: Use dev_kfree_skb in Tx cleanup path
Date: Fri, 01 May 2015 11:36:59 -0400 (EDT)
Message-ID: <20150501.113659.1615816780747363615.davem@davemloft.net>
References: <20150501093420.GA11669@electric-eye.fr.zoreil.com>
	<55436C4B.7090509@gmx.de>
	<55436E6E.5050609@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, nic_swsd@realtek.com,
	Dept-HSGLinuxNICDev@qlogic.com, sony.chacko@qlogic.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	ebiederm@xmission.com
To: LinoSanfilippo@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753625AbbEAPhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 11:37:03 -0400
In-Reply-To: <55436E6E.5050609@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Fri, 01 May 2015 14:15:42 +0200

> On 01.05.2015 14:06, Lino Sanfilippo wrote:
> 
>> which did just the opposite: replace dev_kfree() with dev_kfree_any()
>> for that reason. See
>> 
> 
> Um, this should of course be dev_kfree_skb() and dev_kfree_skb_any().

Indeed.

Alex, you can't make this change.  netconsole transmits can occur
from any context whatsoever.
