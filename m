From: Andy Cress <andycress@gmail.com>
Subject: [PATCH 0/4] pch_gbe: avoiding transmit timeouts (rev3)
Date: Thu, 26 Jul 2012 11:57:09 -0400
Message-ID: <20120726155709.GA10287@telcoserv5>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:58906 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436Ab2GZPzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 11:55:36 -0400
Received: by vbbff1 with SMTP id ff1so1792402vbb.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 08:55:36 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When the interface is stressed with 6 VLANs, some transmit timeout stats were 
observed, which is a potential precursor to the more severe netdev watchdog 
timeout oops.  Also we saw more than the expected number of transmit restarts, which impacted performance.   The following patches were applied and resolved 
the symptom of the transmit timeout stats, and reduced the number of 
transmit restarts.  

This patch set includes the following patches:
0001-pch_gbe-fix-transmit-watchdog-timeout.patch
0002-pch_gbe-add-extra-clean-tx.patch  (includes bumping the version to 1.01) 
0003-pch_gbe-vlan-skb-len-fix.patch

This rev3 has the following changes:
* Removed Fix-the-checksum-fill-to-the-error-location.patch for now so Hongbo can evaluate/revise/test based on feedback.

The resulting pch_gbe 1.01 driver has been tested on Kontron Tunnel Creek 
EG20T modules and Intel Crown Bay EG20T modules, so I believe that these are 
appropriate for consideration in the upstream pch_gbe driver.

Please review and comment.

Thanks,
Andy
