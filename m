From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: natsemi: ns83820: add checks for dma mapping
 error
Date: Mon, 24 Apr 2017 14:04:55 -0400 (EDT)
Message-ID: <20170424.140455.190776456596552748.davem@davemloft.net>
References: <20170417.151743.1779341653983811894.davem@davemloft.net>
        <1492866365-5422-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55498 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S975067AbdDXSE5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 14:04:57 -0400
In-Reply-To: <1492866365-5422-1-git-send-email-khoroshilov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 22 Apr 2017 16:06:05 +0300

> +		free_idx = (free_idx + NR_TX_DESC - 1) % NR_TX_DESC;

This is more simply stated as "(free_idx - 1) % NR_TX_DESC.
