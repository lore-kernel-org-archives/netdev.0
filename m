From: David Miller <davem@davemloft.net>
Subject: Re: usbnet: fix misc bugs
Date: Wed, 02 May 2012 20:14:44 -0400 (EDT)
Message-ID: <20120502.201444.2074945018843883757.davem@davemloft.net>
References: <1335775864-4873-1-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: tom.leiming@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37858 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755Ab2ECAQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 20:16:21 -0400
In-Reply-To: <1335775864-4873-1-git-send-email-tom.leiming@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ming Lei <tom.leiming@gmail.com>
Date: Mon, 30 Apr 2012 16:51:01 +0800

> These patches fix three bugs in usbnet:
> 	usbnet: fix leak of transfer buffer of dev->interrupt
> 	usbnet: fix failure handling in usbnet_probe
> 	usbnet: fix skb traversing races during unlink(v1)

The third fix looks quite critical, but depends upon an interface
not present in Linus's tree, nor mine.  That doesn't work.

You need to find a way to propagate this fix into Linus's tree
as well as all -stable trees that need that fix, but without
this unmet dependency.
