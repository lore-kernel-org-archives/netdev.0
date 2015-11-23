From: Anjali Singhai Jain <anjali.singhai@intel.com>
Subject: [PATCH 0/6] Generalize udp based tunnels and add geneve offload
Date: Mon, 23 Nov 2015 13:02:53 -0800
Message-ID: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48052 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755088AbbKWUqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 15:46:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series generalizes the flow for udp_based tunnels for
offload hooks. So that much of the frame work can remain common
for any driver adding support for geneve or any other
udp_based tunnel in future.

This patch series also makes the driver calls to/from the stack
independent of the tunnel modules. So it would be easier to remove
module config parameters from the respective drivers for tunnel
support. One such example is in i40e driver.

This patch series also adds support for geneve offload in i40e driver.

Much thanks to Jesse Gross for his valuable feedback in getting this
done the right way.

Anjali Singhai Jain (6):
net: Generalize udp based tunnel offload
net: Add a generic udp_offload_get_port function
i40e: Generalize the flow for udp based tunnels
i40e: Remove CONFIG_I40E_VXLAN
net: Refactor udp_offload and add Geneve port offload
i40e:Add geneve tunnel offload support
