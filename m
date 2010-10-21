From: nhorman@tuxdriver.com
Subject: [PATCH] tipc: revert some previously ABI breaking changes to the user space tipc interface
Date: Thu, 21 Oct 2010 07:06:14 -0400
Message-ID: <1287659176-14504-1-git-send-email-nhorman@tuxdriver.com>
Cc: davem@davemloft.net, jon.maloy@ericsson.com,
	paul.gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, luca@llucax.com.ar,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49635 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757023Ab0JULGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:06:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on discussions with Leandro Lucarella and Jon Maloy, it appears we've
managed to break the TIPC user space ABI.  While it would be really nice to have
some level of consistency in regards to on the wire byte order, we can't do that
if it breaks user space.  This patch series reverts the offending patches that
caused this, and puts us back in a state that allows user space to work
properly.  We can now go back and look at methods to get consistent on the wire
byte order while maintaining host byte order in the user space API.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
