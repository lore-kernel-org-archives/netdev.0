From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] usbnet: fix failure handling in usbnet_probe
Date: Wed, 02 May 2012 20:13:42 -0400 (EDT)
Message-ID: <20120502.201342.1392207509614929669.davem@davemloft.net>
References: <1335775864-4873-1-git-send-email-tom.leiming@gmail.com>
	<1335775864-4873-3-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: tom.leiming@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37830 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539Ab2ECANr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 20:13:47 -0400
In-Reply-To: <1335775864-4873-3-git-send-email-tom.leiming@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ming Lei <tom.leiming@gmail.com>
Date: Mon, 30 Apr 2012 16:51:03 +0800

> If register_netdev returns failure, the dev->interrupt and
> its transfer buffer should be released, so just fix it.
> 
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>

Applied.
