From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 09/10] bnx2x: Added FW GRO bridging support
Date: Mon, 14 Jan 2013 10:44:35 -0800
Message-ID: <1358189075.8744.3320.camel@edumazet-glaptop>
References: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
	 <1358176310-31504-10-git-send-email-yuvalmin@broadcom.com>
	 <1358184123.8744.3127.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	ariele@broadcom.com
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:52755 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755896Ab3ANSoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 13:44:38 -0500
Received: by mail-pb0-f52.google.com with SMTP id ro2so2301552pbb.11
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 10:44:38 -0800 (PST)
In-Reply-To: <1358184123.8744.3127.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-14 at 09:22 -0800, Eric Dumazet wrote:

> This looks weird to me. This should be called by GRO stack only.
> 
> What is the value of gso_segs ?
> 
> 

The reason I am pointing this out is the recent change in commit
1def9238d4aa2146924994aa4b7dc861f03b9362
(net_sched: more precise pkt_len computation)

bnx2x not setting gso_segs means that qdisc accounting on ingress is
completely wrong.
