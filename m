From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tun: remove useless codes in tun_chr_aio_read()
 and tun_recvmsg()
Date: Mon, 09 Dec 2013 20:36:46 -0500 (EST)
Message-ID: <20131209.203646.425478975392590777.davem@davemloft.net>
References: <1386363300-19040-1-git-send-email-zwu.kernel@gmail.com>
	<1386363300-19040-2-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	wuzhy@linux.vnet.ibm.com
To: zwu.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab3LJBgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 20:36:48 -0500
In-Reply-To: <1386363300-19040-2-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <zwu.kernel@gmail.com>
Date: Sat,  7 Dec 2013 04:55:00 +0800

> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
> By checking related codes, it is impossible that ret > len or total_len,
> so we should remove some useless codes in both above functions.
> 
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Applied.
