From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next 3/7] inetpeer: use generic union inet_addr
Date: Mon, 22 Jul 2013 08:18:35 -0700
Message-ID: <1374506315.4990.14.camel@edumazet-glaptop>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
	 <1374476713-8838-4-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:56710 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756092Ab3GVPSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 11:18:39 -0400
Received: by mail-pd0-f174.google.com with SMTP id 10so6944632pdc.19
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 08:18:39 -0700 (PDT)
In-Reply-To: <1374476713-8838-4-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 15:05 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> struct inetpeer_addr is pretty similar to generic union inet_addr,
> therefore can be safely converted to it.

Its 'safe' but adds 50% increase for struct tcp_metrics_block

I fail to see this mentioned in the changelog.

I guess its no big deal, but why do you think this code used hand coded
functions instead of generic ?
