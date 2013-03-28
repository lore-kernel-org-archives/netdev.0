From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/2] sky2: Receive Overflows not counted
Date: Thu, 28 Mar 2013 14:40:20 -0700
Message-ID: <20130328144020.138cdc71@nehalam.linuxnetplumber.net>
References: <1902752B0C92F943AB7EA9EE13E2DEEC7F1545@HQ1-EXCH02.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mirko Lindner <mlindner@marvell.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:63704 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766Ab3C1Vkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 17:40:33 -0400
Received: by mail-pa0-f44.google.com with SMTP id bi5so87035pad.31
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 14:40:33 -0700 (PDT)
In-Reply-To: <1902752B0C92F943AB7EA9EE13E2DEEC7F1545@HQ1-EXCH02.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The sky2 driver doesn't count the Receive Overflows because the MAC 
> interrupt for this event is not set in the MAC's interrupt mask.
> The MAC's interrupt mask is set only for Transmit FIFO Underruns.
> 
> Fix: The correct setting should be (GM_IS_TX_FF_UR | GM_IS_RX_FF_OR)
> Otherwise the Receive Overflow event will not generate any interrupt.
> The  Receive Overflow interrupt is handled correctly
> 
> Signed-off-by: Mirko Lindner <mlindner@marvell.com>

Both these patches are fine, but the patch format seems corrupted since
they won't directly apply with quilt.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
