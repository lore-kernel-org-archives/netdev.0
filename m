From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers/net/: use DEFINE_PCI_DEVICE_TABLE()
Date: Thu, 07 Jan 2010 14:25:46 -0800
Message-ID: <1262903146.10429.83.camel@Joe-Laptop.home>
References: <20100107215811.GA9357@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1640 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750786Ab0AGWZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 17:25:47 -0500
In-Reply-To: <20100107215811.GA9357@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-01-07 at 23:58 +0200, Alexey Dobriyan wrote:
> Use DEFINE_PCI_DEVICE_TABLE() so we get place PCI ids table into correct section
> in every case.

Good idea, but aren't there are some tables that are not const?



