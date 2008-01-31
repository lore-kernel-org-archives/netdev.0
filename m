From: "Denis V. Lunev" <den@sw.ru>
Subject: [PATCH 0/3] [RAW]: proc output cleanups.
Date: Thu, 31 Jan 2008 14:32:52 +0300
Message-ID: <47A1B1E4.2010804@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, devel@openvz.org,
	xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:56066 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757659AbYAaLcx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 06:32:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

yesterday Adrian Bunk noticed, that the commit

commit 42a73808ed4f30b739eb52bcbb33a02fe62ceef5
Author: Pavel Emelyanov <xemul@openvz.org>
Date:   Mon Nov 19 22:38:33 2007 -0800

is somewhat strange. Basically, the commit is obviously wrong as the
content of the /proc/net/raw6 is incorrect due to it.

This series of patches fixes original problem and slightly cleanups the
code around.

Signed-off-by: Denis V. Lunev <den@openvz.org>

