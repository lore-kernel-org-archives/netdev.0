From: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Subject: Re: [PATCH 3/4] bonding: Fix work rearming
Date: Wed, 16 Jan 2008 12:28:45 +0900
Message-ID: <478D79ED.5080509@miraclelinux.com>
References: <20080115090532.GB1696@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:50128 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756383AbYAPDal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 22:30:41 -0500
In-Reply-To: <20080115090532.GB1696@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > Though message in bonding_store_miimon() says miimon value 1-INT_MAX
 > rejected, but it looks like 0 can be accepted and monitor must be
 > stopped in that case.
=> miimon value *not in range* 1-INT_MAX

-- 
Makito SHIOKAWA
MIRACLE LINUX CORPORATION
