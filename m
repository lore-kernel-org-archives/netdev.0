From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: unmask intr only when napi is complete
Date: Tue, 23 May 2017 11:06:08 -0400 (EDT)
Message-ID: <20170523.110608.1602668006680330478.davem@davemloft.net>
References: <20170522191948.1397-1-gvaradar@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com
To: gvaradar@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35998 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933515AbdEWPGM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:06:12 -0400
In-Reply-To: <20170522191948.1397-1-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Date: Mon, 22 May 2017 12:19:48 -0700

> In case of busy poll, napi_complete_done returns false and does not
> dequeue napi. In this case do not unmask the intr. We are guaranteed
> napi is called again. This reduces unnecessary iowrites.
> 
> Signed-off-by: Govindarajulu Varadarajan <gvaradar@cisco.com>

Looks good, applied, thank you.
