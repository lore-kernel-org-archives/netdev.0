From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Quota in __qdisc_run()
Date: Tue, 07 Oct 2014 10:32:12 -0700
Message-ID: <1412703132.11091.144.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141007153050.792c9743@redhat.com>
	 <1412693013.4140057.176149461.0FBF6CBD@webmail.messagingengine.com>
	 <1412694080.11091.131.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141007.131938.1410434352331637585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, brouer@redhat.com,
	netdev@vger.kernel.org, therbert@google.com, fw@strlen.de,
	dborkman@redhat.com, jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:33398 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754399AbaJGRcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 13:32:20 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so5344767pdb.7
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 10:32:19 -0700 (PDT)
In-Reply-To: <20141007.131938.1410434352331637585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-07 at 13:19 -0400, David Miller wrote:

> Yes, this makes sense, do a full qdisc_restart() cycle without boundaries,
> then check how much quota was used afterwards to guard the outermost loop.

I am testing this, and also am testing the xmit_more patch for I40E.

Will send patches today.

Thanks
