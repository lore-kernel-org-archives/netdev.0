From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: No GSOs to i40e with VXLAN
Date: Fri, 13 Jun 2014 17:15:57 -0700 (PDT)
Message-ID: <alpine.LFD.2.11.1406131657240.4926@fvl-a0.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52181 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754292AbaFNAMt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jun 2014 20:12:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I quickly tested VXLAN on i40e with net-next with commit id 
f9da455b93f6ba076935b4ef4589f61e529ae046 and the i40e driver has stopped 
receiving GSOs even when advertising tx-udp_tnl-segmentation which means 
our VXLAN segmentation offload. I am guessing this has something to do
with Tom's recent UDP work but this is just a guess as unfortunatly I
do not have the time to debug this, but I am signing up to review and test 
patches fixing this issue.

The driver still gets GSOs with non VXLAN traffic (tested with TCP).

Thanks

Joseph
