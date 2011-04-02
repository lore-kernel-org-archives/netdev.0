From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/fec: do not pass NULL dev to DMA API
Date: Sat, 02 Apr 2011 00:57:14 -0700 (PDT)
Message-ID: <20110402.005714.258110130.davem@davemloft.net>
References: <1301726391-7431-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: b29396@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36500
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752690Ab1DBH5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2011 03:57:52 -0400
In-Reply-To: <1301726391-7431-1-git-send-email-b29396@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


First, your patches never make it to the mailing list because the list
server rejects your postings, due to the fact that there are syntax
errors in your email headers:

Illegal-Object:	Syntax error in From: address found on vger.kernel.org:
	From:	Aisheng.Dong<b29396@freescale.com>
				    ^-missing end of mailbox

Second, this patch does not apply to the current tree at all.
This bug has already been fixed and there are no cases where
a NULL device is passed to the DMA API interfaces any more.
