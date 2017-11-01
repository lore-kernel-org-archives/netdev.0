From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ppp: Destroy the mutex when cleanup
Date: Wed, 01 Nov 2017 21:21:52 +0900 (KST)
Message-ID: <20171101.212152.1217584341582256505.davem@davemloft.net>
References: <1509445537-39319-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53012 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752066AbdKAMV5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 08:21:57 -0400
In-Reply-To: <1509445537-39319-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@vip.163.com
Date: Tue, 31 Oct 2017 18:25:37 +0800

> From: Gao Feng <gfree.wind@vip.163.com>
> 
> The mutex_destroy only makes sense when enable DEBUG_MUTEX. For the
> good readbility, it's better to invoke it in exit func when the init
> func invokes mutex_init.
> 
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>

Applied.
