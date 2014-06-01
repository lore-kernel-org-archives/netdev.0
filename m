From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 3.14-stable] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Sun, 1 Jun 2014 15:38:53 +0800
Message-ID: <20140601073853.GA8635@richard>
References: <1401607475-8367-1-git-send-email-weiyang@linux.vnet.ibm.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Bjorn Helgaas <bhelgaas@google.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:44256 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbaFAHjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 03:39:00 -0400
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Sun, 1 Jun 2014 17:38:58 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id A24E83578052
	for <netdev@vger.kernel.org>; Sun,  1 Jun 2014 17:38:56 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s517HGdf4522250
	for <netdev@vger.kernel.org>; Sun, 1 Jun 2014 17:17:16 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s517ctff032040
	for <netdev@vger.kernel.org>; Sun, 1 Jun 2014 17:38:56 +1000
Content-Disposition: inline
In-Reply-To: <1401607475-8367-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Following are the backport of this patch to 3.14, 3.10, 3.4 and 3.2 stable
tree.

On 3.14, only this patch is backported.
On 3.10, a previous related one "pass pci_device_id.driver_data to
         __mlx4_init_one during reset" is backported too.
On 3.4,  "pass pci_device_id.driver_data to __mlx4_init_one during reset" is
         not backported, since the slot_reset handler is not presented.
	 While another one, "Stash PCI ID driver_data in mlx4_priv structure"
	 is backported to make this patch valid on this version.
On 3.2,  The same as 3.4.

All version are compiled successfully. 3.14 and 3.10 are verified, while 3.4
and 3.2 are not.

I am not sure how to make them all in one big patch set, so send them
seperatedly. Each version is contained in one patch set. If there is a better
way for you to merge them, please let me know.

At last, Happy Children's Day for all :-)

-- 
Richard Yang
Help you, Help me
