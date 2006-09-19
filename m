From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3][ATM]: [he] don't hold the device lock when
 upcalling
Date: Tue, 19 Sep 2006 12:59:46 -0700 (PDT)
Message-ID: <20060919.125946.04055080.davem@davemloft.net>
References: <200609170019.k8H0J2eS025296@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32658
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752041AbWIST7l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 15:59:41 -0400
To: chas@cmf.nrl.navy.mil
In-Reply-To: <200609170019.k8H0J2eS025296@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Sat, 16 Sep 2006 20:19:02 -0400

> please consider for 2.6.18 -- thanks!
> 
> [ATM]: [he] don't hold the device lock when upcalling
> 
> This can create a deadlock/lock ordering problem with other layers that
> want to use the transmit (or other) path of the card at that time.
> 
> Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

Applied, thanks.
