From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] bonding: use rtnl_deref in
 bond_change_rx_flags()
Date: Thu, 17 Jul 2014 08:54:44 +0200
Message-ID: <1405580084.10255.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405528321-19877-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:42872 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753603AbaGQGyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 02:54:50 -0400
Received: by mail-wi0-f172.google.com with SMTP id n3so7342950wiv.11
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 23:54:48 -0700 (PDT)
In-Reply-To: <1405528321-19877-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-07-16 at 18:32 +0200, Veaceslav Falico wrote:
> As it's always called with RTNL held, via dev_set_allmulti/promiscuity.
> Also, remove the wrong comment.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
