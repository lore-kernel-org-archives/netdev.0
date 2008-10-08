From: David Miller <davem@davemloft.net>
Subject: Re: forcedeth: add pci_enable_device() to nv_resume()
Date: Wed, 08 Oct 2008 15:37:58 -0700 (PDT)
Message-ID: <20081008.153758.255096487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ranma+kernel@tdiedrich.de, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: simon@fire.lp0.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59331
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754981AbYJHWiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 18:38:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm not going to apply this patch, it doesn't even fix the reported
bug.

If anything, the patch which apparently broke things,
25d90810ff49d2a63475776f24c74c6bb49b045f ("[netdrvr] forcedeth:
reorder suspend/resume code") should be reverted unless we can come up
with a fix "real fast".

