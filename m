From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 0/11 v2] bnx2x: ethtool and other enhancements
Date: Tue, 19 Jun 2012 20:48:21 +0300
Message-ID: <1340128112-22935-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2665 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754436Ab2FSOlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 10:41:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series adds few features to bnx2x:
Add support for external LB in ethtool self-test
Enable UDP RSS on 4-tupple, controlled by ethtool
Support up to 63 RSS queues (rather than 16)
Add support for setting the desired number of RSS queues via ethtool
Allow to configure dcbx admin params from all drivers on a single physical port
Add FCoE capabilities advertisement

Differences comparing to v1:
1. Remove the default (8) for the maximum number of RSS queues. We are still
   working on the global rfc to set the default for all drivers, and that series
   will include the patch for bnx2x as well.
2. Correct indentation in bnx2x_initial_phy_init function.
3. In bnx2x_get_rss_flags set info->data = 0 for any type for which RSS is not
   supported.
4. In few places change from if(rc != 0) to if(rc)
5. In bnx2x_get_channels don't set fields to 0 as the ethtool core already does
   that
6. In bnx2x_set_channels add a check for combined_count = 0
7. Remove patch "write FCoE capabilities to chip" since we want to add related
   changes in storage drivers (bnx2fc, bnx2i, cnic).

Please consider applying this patch series to net-next.

Thanks,
Merav
