From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2 v2] qlcnic: using too much stack
Date: Tue, 10 Aug 2010 01:34:52 -0700 (PDT)
Message-ID: <20100810.013452.70206967.davem@davemloft.net>
References: <20100810074936.GG18431@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, anirban.chakraborty@qlogic.com,
	linux-driver@qlogic.com, sucheta.chakraborty@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46411
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751969Ab0HJIed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 04:34:33 -0400
In-Reply-To: <20100810074936.GG18431@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Tue, 10 Aug 2010 09:49:36 +0200

> qlcnic_pci_info structs are 128 bytes so an array of 8 uses 1024 bytes.
> That's a lot if you run with 4K stacks.  I allocated them with kcalloc()
> instead.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
