From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 0/4] sctp: Updates and fixes
Date: Fri, 13 Feb 2009 13:33:40 -0500
Message-ID: <1234550024-30915-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:32524 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbZBMSdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 13:33:46 -0500
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Here are some updates and fixes for SCTP:
    - Allow disabling of checksum with a module parameter.
    - Cleanup the sctp checksum code to get rid of excessive casts
    - Fix the exponention RTO update with Heartbeats.
    - Preserve socket level options on accept/peeloff.

Thanks
-vlad
