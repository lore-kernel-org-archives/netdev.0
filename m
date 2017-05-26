From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: llc: add lock_sock in llc_ui_bind to avoid a race
 condition
Date: Fri, 26 May 2017 14:24:05 -0400 (EDT)
Message-ID: <20170526.142405.1523981438362847832.davem@davemloft.net>
References: <1495692438-9781-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xiaolou4617@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43194 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753907AbdEZSYH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 14:24:07 -0400
In-Reply-To: <1495692438-9781-1-git-send-email-xiaolou4617@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lin Zhang <xiaolou4617@gmail.com>
Date: Thu, 25 May 2017 14:07:18 +0800

> There is a race condition in llc_ui_bind if two or more processes/threads 
> try to bind a same socket.
> 
> If more processes/threads bind a same socket success that will lead to 
> two problems, one is this action is not what we expected, another is 
> will lead to kernel in unstable status or oops(in my simple test case, 
> cause llc2.ko can't unload).
> 
> The current code is test SOCK_ZAPPED bit to avoid a process to 
> bind a same socket twice but that is can't avoid more processes/threads 
> try to bind a same socket at the same time.
> 
> So, add lock_sock in llc_ui_bind like others, such as llc_ui_connect.
> 
> Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>

Applied, thank you.
