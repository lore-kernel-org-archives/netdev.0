From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 0/2] cpsw: fix resource leak for v3.8
Date: Sat,  3 Nov 2012 09:25:28 +0100
Message-ID: <cover.1351930782.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:45998 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826Ab2KCIZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 04:25:42 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1628106eaa.19
        for <netdev@vger.kernel.org>; Sat, 03 Nov 2012 01:25:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking at the idea of removing all of the register offsets in
the CPSW's device tree, I noticed that the driver would be leaking IO
mappings. Although this is, strictly speaking, a bug fix, still it can
wait to appear in v3.8, since there is no way to use the driver in
v3.7 (or earlier) anyhow.

Thanks,
Richard


Richard Cochran (2):
  cpsw: rename register banks to match the reference manual, part 2
  cpsw: fix leaking IO mappings

 drivers/net/ethernet/ti/cpsw.c |   39 +++++++++++++++++++--------------------
 1 files changed, 19 insertions(+), 20 deletions(-)

-- 
1.7.2.5
