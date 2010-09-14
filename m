From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: fix PAL state machine restart on resume
Date: Tue, 14 Sep 2010 14:31:15 -0700 (PDT)
Message-ID: <20100914.143115.124060138.davem@davemloft.net>
References: <1284451921-9937-1-git-send-email-simon@sequanux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sguinot@lacie.com
To: simon@sequanux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37302
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750834Ab0INVa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 17:30:57 -0400
In-Reply-To: <1284451921-9937-1-git-send-email-simon@sequanux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Guinot <simon@sequanux.org>
Date: Tue, 14 Sep 2010 10:12:01 +0200

> From: Simon Guinot <sguinot@lacie.com>
> 
> On resume, before starting the PAL state machine, check if the
> adjust_link() method is well supplied. If not, this would lead to a
> NULL pointer dereference in the phy_state_machine() function.
> 
> This scenario can happen if the Ethernet driver call manually the PHY
> functions instead of using the PAL state machine. The mv643xx_eth driver
> is a such example.
> 
> Signed-off-by: Simon Guinot <sguinot@lacie.com>

Applied, thanks.
