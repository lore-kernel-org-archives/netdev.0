From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/3] jme: Protect vlgrp structure by pause RX
 actions.
Date: Thu, 18 Mar 2010 21:14:23 -0700 (PDT)
Message-ID: <20100318.211423.232742148.davem@davemloft.net>
References: <1268820571-2092-1-git-send-email-cooldavid@cooldavid.org>
	<1268820571-2092-2-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ethanhsiao@jmicron.com,
	devinchiu@jmicron.com, hcchao@jmicron.com, stable@kernel.org
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38276
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750748Ab0CSEOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 00:14:01 -0400
In-Reply-To: <1268820571-2092-2-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: cooldavid@cooldavid.org
Date: Wed, 17 Mar 2010 18:09:30 +0800

> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
> 
> Temporary stop the RX IRQ, and disable (sync) tasklet or napi.
> And restore it after finished the vlgrp pointer assignment.
> 
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Applied.
