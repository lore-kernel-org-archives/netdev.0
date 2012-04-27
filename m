From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v2 0/2] drop_monitor: misc fixes for some recently reported bugs
Date: Fri, 27 Apr 2012 16:11:47 -0400
Message-ID: <1335557509-32726-1-git-send-email-nhorman@tuxdriver.com>
References: <1335466022-32661-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44510 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078Ab2D0UL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 16:11:59 -0400
In-Reply-To: <1335466022-32661-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey-
        Eric was using dropwatch recently and reported a few bugs to me that he
had noted.  This short series should fix them all up.

Change Notes:
V2)
	renamed trace_state_lock to trace_state_mutex
	cleaned up rcu write side access to use rcu_dereference_protected
	handled some NULL allocation failure cases


Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: David Miller <davem@davemloft.net>
