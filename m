From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/8] xen-netback: support toeplitz hashing
Date: Fri, 12 Feb 2016 11:41:46 -0500 (EST)
Message-ID: <20160212.114146.557404301623026279.davem@davemloft.net>
References: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
	<20160212.055408.1901988218281607996.davem@davemloft.net>
	<47dcce9fc54b42f591284cd8ea72ddba@AMSPEX02CL03.citrite.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
To: Paul.Durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbcBLQl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 11:41:57 -0500
In-Reply-To: <47dcce9fc54b42f591284cd8ea72ddba@AMSPEX02CL03.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <Paul.Durrant@citrix.com>
Date: Fri, 12 Feb 2016 11:07:50 +0000

> Windows *requires* use of Teoplitz so your position completely rules
> out being able to support receive side scaling in Windows PV
> frontends on Linux kernel backends, not only for Xen but for any
> other hypervisor, which I think is totally unreasonable.

We have strong reason to believe that Toeplitz has properties that
make it very weak if not exploitable, therefore doing software RSS
with Jenkins is superior.
