From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH V3 4/6] i40e: queue-specific settings for interrupt
 moderation
Date: Thu, 14 Jan 2016 22:41:41 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFE59DA@fmsmsx115.amr.corp.intel.com>
References: <1452780487-10581-1-git-send-email-kan.liang@intel.com>
 <1452780487-10581-4-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	"dsahern@gmail.com" <dsahern@gmail.com>,
	"tj@kernel.org" <tj@kernel.org>,
	"cascardo@redhat.com" <cascardo@redhat.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"ben@decadent.org.uk" <ben@decadent.org
To: "Liang, Kan" <kan.liang@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bwh@kernel.org" <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:6136 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755179AbcANWlm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 17:41:42 -0500
In-Reply-To: <1452780487-10581-4-git-send-email-kan.liang@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Kan Liang <kan.liang@intel.com>
> 
> For i40e driver, each vector has its own ITR register. However, there
> are no concept of queue-specific settings in the driver proper. Only
> global variable is used to store ITR values. That will cause problems
> especially when resetting the vector. The specific ITR values could be
> lost.
> This patch move rx_itr_setting and tx_itr_setting to i40e_ring to store
> specific ITR register for each queue.
> i40e_get_coalesce and i40e_set_coalesce are also modified accordingly to
> support queue-specific settings. To make it compatible with old ethtool,
> if user doesn't specify the queue number, i40e_get_coalesce will return
> queue 0's value. While i40e_set_coalesce will apply value to all queues.
> 
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
> 

Acked-by: Shannon Nelson <shannon.nelson@intel.com>
