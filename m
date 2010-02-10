From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] DMFE: move pci ID definitions into pci_ids.h and
 clean up the code
Date: Wed, 10 Feb 2010 13:18:49 -0800 (PST)
Message-ID: <20100210.131849.237007566.davem@davemloft.net>
References: <1265487542-4447-1-git-send-email-maximlevitsky@gmail.com>
	<1265487542-4447-3-git-send-email-maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	maxim-levitsky@gmail.com
To: maximlevitsky@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39773
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755569Ab0BJVSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 16:18:35 -0500
In-Reply-To: <1265487542-4447-3-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxim Levitsky <maximlevitsky@gmail.com>
Date: Sat,  6 Feb 2010 22:18:58 +0200

> Signed-off-by: Maxim Levitsky <maxim-levitsky@gmail.com>

We don't add new definitions to pci_ids.h that will only
be used in a single driver.

Instead, we just use the raw constants (if it's only referenced once,
say in the PCI ID table for the driver) or using local definitions
(if used multiple times in the driver).
