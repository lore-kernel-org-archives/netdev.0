From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] sch_htb: let skb->priority refer to non-leaf class
Date: Wed, 22 Jan 2014 06:47:48 -0800
Message-ID: <1390402068.27806.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389883519.4703.5.camel@azathoth.dev.smoothwall.net>
	 <1389889520.31367.403.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1389953999.4698.18.camel@azathoth.dev.smoothwall.net>
	 <52D927CD.4080403@cogentembedded.com>
	 <1389964952.4698.20.camel@azathoth.dev.smoothwall.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	linux-netdev <netdev@vger.kernel.org>
To: Harry Mason <harry.mason@smoothwall.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:58090 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754455AbaAVOru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 09:47:50 -0500
Received: by mail-pd0-f176.google.com with SMTP id w10so451141pde.21
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 06:47:49 -0800 (PST)
In-Reply-To: <1389964952.4698.20.camel@azathoth.dev.smoothwall.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-17 at 13:22 +0000, Harry Mason wrote:
> If the class in skb->priority is not a leaf, apply filters from the
> selected class, not the qdisc. This lets netfilter or user space
> partially classify the packet.
> 
> Signed-off-by: Harry Mason <harry.mason@smoothwall.net>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
