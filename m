From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: irda: using kzalloc() instead of kmalloc() to
 avoid strncpy() issue.
Date: Sun, 19 May 2013 15:11:12 -0700 (PDT)
Message-ID: <20130519.151112.787320797896644755.davem@davemloft.net>
References: <5195F4A0.3000708@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215Ab3ESWLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 18:11:12 -0400
In-Reply-To: <5195F4A0.3000708@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>
Date: Fri, 17 May 2013 17:13:04 +0800

> 
> 'discovery->data.info' length is 22, NICKNAME_MAX_LEN is 21, so the
> strncpy() will always left the last byte of 'discovery->data.info'
> uninitialized.
> 
> When 'text' length is longer than 21 (NICKNAME_MAX_LEN), if still left
> the last byte of 'discovery->data.info' uninitialized, the next
> strlen() will cause issue.
> 
> Also 'discovery->data' is 'struct irda_device_info' which defined in
> "include/uapi/...", it may copy to user mode, so need whole initialized.
> 
> All together, need use kzalloc() instead of kmalloc() to initialize all
> members firstly.
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>

Applied, thanks.
