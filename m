From: David Miller <davem@davemloft.net>
Subject: Re: [NEXT PATCH 1/3] qlcnic: fix memory leak in qlcnic_blink_led.
Date: Thu, 28 Apr 2011 13:44:00 -0700 (PDT)
Message-ID: <20110428.134400.232730364.davem@davemloft.net>
References: <1303951426-4341-1-git-send-email-amit.salecha@qlogic.com>
	<1303951426-4341-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com, sucheta.chakraborty@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45445
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752243Ab1D1Uod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 16:44:33 -0400
In-Reply-To: <1303951426-4341-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Wed, 27 Apr 2011 17:43:44 -0700

> From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> 
> o Memory allocated in ETHTOOL_ACTIVE mode, is not getting freed. So,
>   in ETHTOOL_ID_INACTIVE mode, return after freeing allocated memory.
> o Using set bit instead of blink_down field, as it is also required
>   in internal Loopback test and etc.
> 
> Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
