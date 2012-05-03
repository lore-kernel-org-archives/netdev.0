From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] usbnet: fix leak of transfer buffer of
 dev->interrupt
Date: Wed, 02 May 2012 20:13:32 -0400 (EDT)
Message-ID: <20120502.201332.1318932828699906268.davem@davemloft.net>
References: <1335775864-4873-1-git-send-email-tom.leiming@gmail.com>
	<1335775864-4873-2-git-send-email-tom.leiming@gmail.com>
	<201204301058.14913.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom.leiming@gmail.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137Ab2ECANn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 20:13:43 -0400
In-Reply-To: <201204301058.14913.oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Mon, 30 Apr 2012 10:58:14 +0200

> Am Montag, 30. April 2012, 10:51:02 schrieb Ming Lei:
>> The transfer buffer of dev->interrupt is allocated in .probe path,
>> but not freed in .disconnet path, so mark the interrupt URB as
>> URB_FREE_BUFFER to free the buffer when the URB is destroyed.
>> 
>> Signed-off-by: Ming Lei <tom.leiming@gmail.com>
> Acked-by: Oliver Neukum <oneukum@suse.de>

Applied.
