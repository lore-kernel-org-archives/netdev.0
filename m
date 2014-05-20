From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net-tun: restructure tun_do_read for better
 sleep/wakeup efficiency
Date: Mon, 19 May 2014 21:52:39 -0700
Message-ID: <1400561559.5367.87.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400278308-25372-1-git-send-email-xii@google.com>
		 <5379CE8D.2030405@redhat.com>
	 <1400508587.5367.37.camel@edumazet-glaptop2.roam.corp.google.com>
	 <537ADD91.4000609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Xi Wang <xii@google.com>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:40218 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbaETEwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 00:52:41 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so6727918pad.30
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 21:52:40 -0700 (PDT)
In-Reply-To: <537ADD91.4000609@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-05-20 at 12:44 +0800, Jason Wang wrote:

> But this changes (sk_data_ready()) has nothing related to switching to
> use __skb_recv_datagram()

I think I will give up at this point, this is becoming too much time to
gain only 15% of cpu.
