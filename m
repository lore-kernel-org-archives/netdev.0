From: Blair Steven <blair.steven@alliedtelesis.co.nz>
Subject: [PATCH] IPsec NAT-T issue
Date: Mon, 13 Jun 2016 11:48:13 +1200
Message-ID: <20160612234814.15460-1-blair.steven@alliedtelesis.co.nz>
Cc: Blair Steven <blair.steven@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:55087 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbcFLXsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 19:48:23 -0400
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id D744D801B8
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 11:48:18 +1200 (NZST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


During testing we have discovered an issue with IPsec NAT-T where the SPI
is over writing the source and dest ports of the UDP header. I'm not
super familiar with this code, but I've found a solution that seems
to work in my setup.

I'd like some feedback on this please, if it's the right thing to be doing
here, or if it should be done elsewhere.

Thanks very much

Blair Steven (1):
  esp: correct offset for ESN when using NAT-T

 net/ipv4/esp4.c | 2 ++
 1 file changed, 2 insertions(+)

-- 
2.8.3
