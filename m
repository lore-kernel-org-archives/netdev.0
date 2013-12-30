From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Fix incorrect spinlock release in stmmac_ptp.c and
 incorrect PTP capabilities detection in PTP initialization.
Date: Sun, 29 Dec 2013 22:38:52 -0500 (EST)
Message-ID: <20131229.223852.1418279531462143872.davem@davemloft.net>
References: <vbridgers2013@gmail.com>
	<1387559974-31872-1-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	rayagond@vayavyalabs.com
To: vbridgers2013@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073Ab3L3Diy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 22:38:54 -0500
In-Reply-To: <1387559974-31872-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridgers2013@gmail.com>
Date: Fri, 20 Dec 2013 11:19:34 -0600

> This patch corrects a problem in stmmac_ptp.c, functions
> stmmac_adjust_time and stmmac_adjust_freq where the incorrect spinlocks 
> were released. This patch also addresses a problem in stmmac_main, 
> function stmmac_init_ptp where the capability detection for 
> advanced timestamping was masked by message masking. 
> 
> This patch was touch tested using linuxptp, and runs without the previously
> observed instabilities. More extensive testing is ongoing.
> 
> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>

Applied, but please provide a more suitable subject line next time.

Subject lines should, after "[PATCH net]" should have an appropriate
prefix followed by a colon and a space.

Here, that would be "stmmac: "

Also, your Subject line is exceedingly long, try to keep it down to
80 columns.  I edited it to be:

stmmac: Fix incorrect spinlock release and PTP cap detection.
