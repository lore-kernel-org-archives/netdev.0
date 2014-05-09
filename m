From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Fix UNDI driver unload
Date: Fri, 09 May 2014 16:02:11 -0400 (EDT)
Message-ID: <20140509.160211.1142514076359669647.davem@davemloft.net>
References: <1399541671-740-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39282 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008AbaEIUCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 16:02:13 -0400
In-Reply-To: <1399541671-740-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Thu, 8 May 2014 12:34:31 +0300

> Commit 91ebb928b "bnx2x: Add support for Multi-Function UNDI" contains a bug
> which prevent the emptying of the device's Rx buffers before reset.
> As a result, on new boards it is likely HW will reach some fatal assertion
> once its interfaces load after UNDI was previously loaded.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Applied, thanks.
