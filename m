From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next]: net: fix dev_set_promiscuity() breakage
Date: Sun, 06 Jul 2008 15:49:21 -0700 (PDT)
Message-ID: <20080706.154921.95985400.davem@davemloft.net>
References: <487144BC.6030609@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wangchen@cn.fujitsu.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33274
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753212AbYGFWtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 18:49:21 -0400
In-Reply-To: <487144BC.6030609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 07 Jul 2008 00:18:36 +0200

>     net: fix dev_set_promiscuity() breakage
>     
>     Commit dad9b335 (netdevice: Fix promiscuity and allmulti overflow) broke
>     dev_set_promiscuity() by returning on success without reprogramming the
>     device.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
