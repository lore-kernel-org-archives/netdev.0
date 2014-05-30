From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] bridge: fix the unbalanced promiscuous count
 when add_if failed
Date: Fri, 30 May 2014 07:34:46 -0700
Message-ID: <20140530073446.14b87673@nehalam.linuxnetplumber.net>
References: <53869842.4060202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	<bridge@lists.linux-foundation.org>,
	netdev <netdev@vger.kernel.org>, <vyasevic@redhat.com>
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:37054 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbaE3Oet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 10:34:49 -0400
Received: by mail-pd0-f171.google.com with SMTP id y13so1015166pdi.30
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 07:34:49 -0700 (PDT)
In-Reply-To: <53869842.4060202@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 May 2014 10:15:30 +0800
Wang Weidong <wangweidong1@huawei.com> wrote:

> As commit 2796d0c648c94("bridge: Automatically manage port
> promiscuous mode."), make the add_if use dev_set_allmulti
> instead of dev_set_promiscuous, so when add_if failed, we
> should do dev_set_allmulti(dev, -1).
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Good catch.
Acked-by: Stephen Hemminger <stephen@networkplumber.org>
