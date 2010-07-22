From: Ben Greear <greearb@candelatech.com>
Subject: [net 0/2]  Clean up netfilter cache on xmit-to-self.
Date: Thu, 22 Jul 2010 12:54:46 -0700
Message-ID: <1279828488-17800-1-git-send-email-greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54547 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933Ab0GVTyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 15:54:49 -0400
Received: from localhost.localdomain (firewall.candelatech.com [70.89.124.249])
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o6MJsmSK025575
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 12:54:49 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are against 2.6.34.1.  The first one may be
worth submitting to stable.  The second one is less critical
and should probably just go in the development tree.

