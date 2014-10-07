From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4_en: remove NETDEV_TX_BUSY
Date: Tue, 07 Oct 2014 05:38:04 -0700
Message-ID: <1412685484.11091.108.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
		 <1412599904.11091.66.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412613035.11091.72.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5433A48E.1040505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:48634 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbaJGMiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 08:38:07 -0400
Received: by mail-pd0-f171.google.com with SMTP id ft15so5017396pdb.16
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 05:38:06 -0700 (PDT)
In-Reply-To: <5433A48E.1040505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-07 at 11:30 +0300, Amir Vadai wrote:

> Reviewed. Also verified that it fixes the deadlock (by sending a large
> burst - larger than ring size). Before this fix, last packet of the
> burst wasn't sent, therefore no doorbell was rang, and the queue was
> stalled.
> 
> BTW, another nice optimization that we hope to send soon, is not to arm
> the CQ unless ringing the doorbell.
> 
> Acked-by: Amir Vadai <amirv@mellanox.com>

This sounds great, thanks Amir
