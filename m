From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net_sched: prio: rollback allocations if
 prio_init() fails
Date: Mon, 13 Jun 2016 10:27:59 -0700
Message-ID: <1465838879.7945.168.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465773707.7945.133.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpXY0Ce5hbXYGOcd-N1tb9BH33JYXFQdmWEbsc5SWYsV8A@mail.gmail.com>
	 <1465792157.7945.145.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1465794231.7945.150.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpWWLTMRUNUeS9=6B3KqA6Tyu0qaUYSRw_PFYFK_mo7Urw@mail.gmail.com>
	 <1465838004.7945.167.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33364 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933683AbcFMR2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:28:01 -0400
Received: by mail-pf0-f169.google.com with SMTP id y124so48238550pfy.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:28:00 -0700 (PDT)
In-Reply-To: <1465838004.7945.167.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-13 at 10:13 -0700, Eric Dumazet wrote:

> Presumably we should commit changes on qdisc only if the whole
> ->change() succeeded, but I guess lot of qdisc are buggy in this
> respect.

I'll post a v2 fixing this issue as well.
