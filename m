From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2 v2] qlcnic: clean up qlcnic_init_pci_info()
Date: Tue, 10 Aug 2010 01:34:47 -0700 (PDT)
Message-ID: <20100810.013447.245408526.davem@davemloft.net>
References: <20100810074756.GF18431@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, anirban.chakraborty@qlogic.com,
	linux-driver@qlogic.com, sucheta.chakraborty@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46406
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751620Ab0HJIe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 04:34:28 -0400
In-Reply-To: <20100810074756.GF18431@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Tue, 10 Aug 2010 09:47:56 +0200

> In the original code we allocated memory conditionally and freed it in
> the error handling unconditionally.  It turns out that this function is
> only called during initialization and "adapter->npars" and
> "adapter->eswitch" are always NULL at the start of the function.  I
> removed those checks.
> 
> Also since I was cleaning things, I changed the error handling for
> qlcnic_get_pci_info() and pulled everything in an indent level.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
