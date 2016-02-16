From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/5] bnx2x: driver updates
Date: Tue, 16 Feb 2016 18:07:56 +0200
Message-ID: <1455638881-2527-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:24646 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932261AbcBPQIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 11:08:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains several changes - the biggest change is the
addition of Geneve NDO support [allows device to perform RSS according
to inner-headers of encapsulated packet, similar to what it does for
vxlan]. It also extends dcbx support, as well as introducing some minor
changes.

Dave,

Please consider applying this series to `net-next'.
[Do notice patch #3 fails checkpatch due to consistency with existing
HSI]

Thanks,
Yuval
-- 
1.8.3.1
