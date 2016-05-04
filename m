From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATC net-next] tcp: must block bh in __inet_twsk_hashdance()
Date: Wed, 04 May 2016 11:22:11 -0700
Message-ID: <1462386131.5535.353.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462320650.5535.334.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160504.005450.32648328658519474.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34814 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124AbcEDSWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 14:22:13 -0400
Received: by mail-pf0-f182.google.com with SMTP id y69so27814600pfb.1
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 11:22:13 -0700 (PDT)
In-Reply-To: <20160504.005450.32648328658519474.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-04 at 00:54 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 03 May 2016 17:10:50 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > __inet_twsk_hashdance() might be called from process context,
> > better block BH before acquiring bind hash and established locks
> > 
> > Fixes: c10d9310edf5 ("tcp: do not assume TCP code is non preemptible")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied.

David, I do not see these two patches in net-next ?

(This one, and the "tcp: fix lockdep splat in tcp_snd_una_update()" one)

Thanks
