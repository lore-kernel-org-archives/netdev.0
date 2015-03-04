From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv2 0/3 net] xen-netback: fix ethtool stats and memory leak
Date: Wed, 4 Mar 2015 11:14:45 +0000
Message-ID: <1425467688-12846-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:27909 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932907AbbCDLO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 06:14:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of bug fixes for netback:
- make ethool stats to report the correct values.
- don't leak 1 MiB every time a VIF is destroyed.

Changes in v2:
- Split 2nd patch into leak fix and refactor patches

David
