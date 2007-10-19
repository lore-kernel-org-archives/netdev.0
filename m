From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/1] remove header_ops bug in qeth driver
Date: Fri, 19 Oct 2007 23:55:38 +0200
Message-ID: <20071019215538.395133000@linux.vnet.ibm.com>
Cc: mschwid2@linux.vnet.ibm.com, apw@shadowen.org,
	linux-kernel@vger.kernel.org, kamalesh@linux.vnet.ibm.com,
	kaber@trash.net
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:42961 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966875AbXJSWAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 18:00:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-- 
Remove qeth driver bug introduced by this commit:

commit 3b04ddde02cf1b6f14f2697da5c20eca5715017f
Author: Stephen Hemminger <shemminger@linux-foundation.org>
Date:   Tue Oct 9 01:40:57 2007 -0700

    [NET]: Move hardware header operations out of netdevice.

