From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/18 v2] isdn: avm: call disable_pci_device() if
 pci_probe() failed
Date: Tue, 10 Aug 2010 01:42:46 -0700 (PDT)
Message-ID: <20100810.014246.15248571.davem@davemloft.net>
References: <1281383439-13988-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, isdn@linux-pingi.de,
	adobriyan@gmail.com, tilman@imap.cc, tj@kernel.org,
	netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36897
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753416Ab0HJIm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 04:42:26 -0400
In-Reply-To: <1281383439-13988-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Mon,  9 Aug 2010 23:50:37 +0400

> Driver should call disable_pci_device() if it returns from pci_probe()
> with error.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied, but please fix the template you're using for the commit
message header and the message itself, because in all of your
patches you've transposed "disable" and "pci" in "pci_disable_device()"

So I have to fix it up two times in every patch I apply of your's.

Thanks.
