From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/3 v4] ipv6: do not disable temp_address when reaching max_address
Date: Thu, 15 Aug 2013 19:36:03 +0200
Message-ID: <20130815173603.GA30746@order.stressinduktion.org>
References: <520B48AE.8050103@huawei.com> <20130814101511.GC16264@order.stressinduktion.org> <520C241A.2030708@huawei.com> <20130815012457.GD13066@order.stressinduktion.org> <520C3A13.3060106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>, kargig@void.gr,
	ppandit@redhat.com
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54251 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab3HORgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 13:36:06 -0400
Content-Disposition: inline
In-Reply-To: <520C3A13.3060106@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 10:16:51AM +0800, Ding Tianhong wrote:
> I am afraid that if remove the max limit from the ipv6_create_tempaddr, the tool flood_route26 attack will create huge address to the temp_list, it will be a huge list,
> may it destroy something or not?

I just tested, no it does not. Because it will only create a temporary address
for each prefix received, which still is limited by max_addresses. But of
course, more review is needed here. Maybe there is still a possibility to DoS?

Now we have to check why these addresses don't go out of tentative state.

Greetings,

  Hannes
