From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/8] xen-netback: support toeplitz hashing
Date: Fri, 12 Feb 2016 05:54:08 -0500 (EST)
Message-ID: <20160212.055408.1901988218281607996.davem@davemloft.net>
References: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbcBLKyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 05:54:11 -0500
In-Reply-To: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Fri, 12 Feb 2016 10:13:17 +0000

> This patch series adds support for frontend-configurable toeplitz hashing
> in xen-netback (on the guest receive side). This support has been testing
> against a Windows frontend and has proven to be sufficient to pass the
> Microsoft HCK NDIS RSS tests.

We want less Toeplitz users, not more of them.  It is a more unsuitable
hash than jhash2.

I'm not applying these patches, sorry.
