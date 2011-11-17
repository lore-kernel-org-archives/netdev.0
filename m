From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH net-next] r8169: Add 64bit statistics
Date: Thu, 17 Nov 2011 15:46:53 +0800
Message-ID: <CABoNC82RO2uvn9TfToAygEspUZnNrefXgO6SGpZoSAayCp3QiA@mail.gmail.com>
References: <20111117064826.GA4429@Desktop-Junchang>
	<0a41dc06-15ab-4cf6-9bbd-3a1556993854@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	nic swsd <nic_swsd@realtek.com>,
	eric dumazet <eric.dumazet@gmail.com>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:41271 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732Ab1KQHqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 02:46:54 -0500
Received: by vcbfk1 with SMTP id fk1so1354904vcb.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 23:46:54 -0800 (PST)
In-Reply-To: <0a41dc06-15ab-4cf6-9bbd-3a1556993854@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You dont need per-cpu since Tx is locked by dev->xmit_lock and
> rx is implicitly single threaded by NAPI.

Thanks.

>You do need to have
> two u64_stat_sync entries (one for Tx and one for Rx).

You mean Rx and Tx will perform on different cores at one moment.
So I need a sync for Tx to protect tx_xxx, and another for Rx to
protect rx_xxx. Is that right?

Thanks.

-- 
--Junchang
