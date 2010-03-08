From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] be2net: remove usage of be_pci_func
Date: Mon, 08 Mar 2010 10:46:34 -0800 (PST)
Message-ID: <20100308.104634.257362723.davem@davemloft.net>
References: <20100308002125.GA18118@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43041
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755340Ab0CHSqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 13:46:15 -0500
In-Reply-To: <20100308002125.GA18118@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Mon, 8 Mar 2010 05:51:27 +0530

> When PCI functions are virtuialized in applications by assigning PCI
> functions to VM (PCI passthrough), the be2net driver in the VM sees a
> different function number. So, use of PCI function number in any
> calculation will break existing code. This patch takes care of it.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
