From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 05/11] net/mlx5e: Support RX multi-packet
 WQE (Striding RQ)
Date: Mon, 18 Apr 2016 05:48:15 -0700
Message-ID: <1460983695.10638.113.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
	 <1460928725-18741-6-git-send-email-saeedm@mellanox.com>
	 <1460939371.10638.97.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:36397 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbcDRMsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 08:48:19 -0400
Received: by mail-qg0-f49.google.com with SMTP id f52so114720470qga.3
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 05:48:19 -0700 (PDT)
In-Reply-To: <1460939371.10638.97.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-04-17 at 17:29 -0700, Eric Dumazet wrote:

> 
> If really you need to allocate physically contiguous memory, have you
> considered converting the order-5 pages into 32 order-0 ones ?

Search for split_page() call sites for examples.
