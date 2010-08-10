From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/18 v2] isdn: avm: call disable_pci_device() if
 pci_probe() failed
Date: Tue, 10 Aug 2010 01:43:04 -0700 (PDT)
Message-ID: <20100810.014304.242143517.davem@davemloft.net>
References: <1281383448-14050-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, isdn@linux-pingi.de,
	adobriyan@gmail.com, tilman@imap.cc, netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36906
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753395Ab0HJImo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 04:42:44 -0400
In-Reply-To: <1281383448-14050-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Mon,  9 Aug 2010 23:50:47 +0400

> Driver should call disable_pci_device() if it returns from pci_probe()
> with error.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied, but as previously mentioned disable_pci_device() is wrong.
