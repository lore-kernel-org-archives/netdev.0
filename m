From: David Miller <davem@davemloft.net>
Subject: Re: [patch next 1/2] netxen: fix msi irq setup
Date: Mon, 18 May 2009 21:47:09 -0700 (PDT)
Message-ID: <20090518.214709.159456069.davem@davemloft.net>
References: <1242285368-1142-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50273
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751070AbZESErL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 00:47:11 -0400
In-Reply-To: <1242285368-1142-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Thu, 14 May 2009 00:16:08 -0700

> The pdev->irq was not saved in netxen_adapter, causing request_irq()
> with invalid irq number.
> 
> This was broken in commit be339aee634d5cb98a8df8d6febe04002ec497f3.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied, but please reference commits also by header line
text.  See below for the actual commit message I used so
you can see how it should be done, thanks!

netxen: fix msi irq setup

The pdev->irq was not saved in netxen_adapter, causing request_irq()
with invalid irq number.

This was broken in commit be339aee634d5cb98a8df8d6febe04002ec497f3
("netxen: fix irq tear down and msix leak.").

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
