From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix Smatch error
Date: Fri, 18 Aug 2017 15:21:34 -0700 (PDT)
Message-ID: <20170818.152134.1056952193944404695.davem@davemloft.net>
References: <20170818200719.GA4685@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33728 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751713AbdHRWVf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 18:21:35 -0400
In-Reply-To: <20170818200719.GA4685@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Fri, 18 Aug 2017 13:07:19 -0700

> From: Intiyaz Basha <intiyaz.basha@cavium.com>
> 
> Fix Smatch error by not dereferencing iq pointer if it's NULL.
> 
> See http://marc.info/?l=kernel-janitors&m=150296723301129&w=2
> 
> Also, remove unnecessary parentheses.
> 
> Fixes: d314ac222829 ("liquidio: moved liquidio_napi_poll to lio_core.c")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
