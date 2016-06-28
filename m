From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH stable] sfc: report supported link speeds on SFP connections
Date: Tue, 28 Jun 2016 11:11:11 +0100
Message-ID: <2b196485-c720-106e-de23-acefe7ee170a@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:27221 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752154AbcF1KLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 06:11:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

Can you queue up this commit for -stable please? The sfc 8000-series
NICs are less tolerant of missing supported link speeds. It applies
cleanly on to 4.5.7 and 4.6.3. The Fixes: commit below is the commit
that introduced the 8000-series PCI IDs.

commit 1974282ab547df7437276c8d4ec47f3d2300f339
Author: Bert Kenward <bkenward@solarflare.com>
Date:   Mon Jun 6 17:29:30 2016 +0100

    sfc: report supported link speeds on SFP connections

    Fixes: dd248f1bc65b49cba622a7e925d90d790e572996

Thanks,

Bert.
