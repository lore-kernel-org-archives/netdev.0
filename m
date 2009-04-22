From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 0/4] bnx2x: Use request_firmware()
Date: Wed, 22 Apr 2009 16:38:50 +0300
Message-ID: <1240407530.18871.46.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladz@broadcom.com,
	"John Wright" <john.wright@hp.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4094 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752297AbZDVNlf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2009 09:41:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch is based on the original idea of John Wright
<john.wright@hp.com>.
It separates FW blob from the sources. Driver will use request_firmware
interface instead.

It includes 4 patches:
1 - inserting the ihex FW (too big for the mailing list, but not
intersting)
2 - the actual patch
3 - removing the old FW BLOB (also too big - but just removal)
4 - version update

The patches were made by Vlad - Thanks Vlad!

Dave - please consider applying for net-next.

Thanks,
Eilon


