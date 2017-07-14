From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix an array overflow when all ext chunks
 are set
Date: Fri, 14 Jul 2017 09:05:45 -0700 (PDT)
Message-ID: <20170714.090545.1943040429462176763.davem@davemloft.net>
References: <3e78f6040b834ee9221cd2ebf539324499a8bb4f.1500041253.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932189AbdGNQFq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 12:05:46 -0400
In-Reply-To: <3e78f6040b834ee9221cd2ebf539324499a8bb4f.1500041253.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 14 Jul 2017 22:07:33 +0800

> Marcelo noticed an array overflow caused by commit c28445c3cb07
> ("sctp: add reconf_enable in asoc ep and netns"), in which sctp
> would add SCTP_CID_RECONF into extensions when reconf_enable is
> set in sctp_make_init and sctp_make_init_ack.
> 
> Then now when all ext chunks are set, 4 ext chunk ids can be put
> into extensions array while extensions array size is 3. It would
> cause a kernel panic because of this overflow.
> 
> This patch is to fix it by defining extensions array size is 4 in
> both sctp_make_init and sctp_make_init_ack.
> 
> Fixes: c28445c3cb07 ("sctp: add reconf_enable in asoc ep and netns")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thanks.
