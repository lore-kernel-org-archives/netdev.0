From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: request for stable inclusion
Date: Wed, 16 Sep 2015 09:41:40 +0300
Message-ID: <55F90F24.5010601@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Carol L Soto <clsoto@us.ibm.com>,
	Matan Barak <matanb@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0057.outbound.protection.outlook.com ([157.56.112.57]:20161
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751739AbbIPGzy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2015 02:55:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Commit 9293267 "net/mlx4_core: Capping number of requested MSIXs to 
MAX_MSIX"  fixes a bug under which the driver doesn't really starts over 
a machine with > 32 cores.

The bug was introduced in 4.2-rc1 but the fix missed 4.2 -- could you 
please push it to 4.2 -stable?

If you prefer that we will submit it directly there, fine too.

thanks,

Or.
