From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 1/6] bonding: simplify and use RCU
 protection for 3ad xmit path
Date: Thu, 05 Sep 2013 07:26:53 -0700
Message-ID: <1378391213.11205.22.camel@edumazet-glaptop>
References: <5228375C.1050105@huawei.com>
	 <20130905134258.GB26163@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:40168 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078Ab3IEO0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 10:26:55 -0400
Received: by mail-pb0-f50.google.com with SMTP id uo5so1864586pbc.37
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 07:26:54 -0700 (PDT)
In-Reply-To: <20130905134258.GB26163@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-05 at 15:42 +0200, Veaceslav Falico wrote:

> Really?
> 
> No. Again - take a look at list_first_or_null_rcu. And its comments.
> 
> I'm sorry that I'm acting that negatively... But if that gets accepted -
> I'll have days of nightmares.
> 
> Try to understand how RCU works, please, before sending patches using it.

BTW, RCU is really hard, even for experimented kernel developers.
