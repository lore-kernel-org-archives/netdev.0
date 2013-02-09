From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Poor TCP bandwidth between network namespaces
Date: Fri, 08 Feb 2013 18:17:10 -0800
Message-ID: <1360376230.6696.7.camel@edumazet-glaptop>
References: <20130204144320.GG1353@tostaky>
	 <20130204225227.GC6898@order.stressinduktion.org>
	 <1360373618.6696.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Emmanuel Jeanvoine <emmanuel.jeanvoine@inria.fr>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36304 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760521Ab3BICRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 21:17:13 -0500
Received: by mail-pa0-f45.google.com with SMTP id kl14so2364744pab.4
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 18:17:12 -0800 (PST)
In-Reply-To: <1360373618.6696.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-08 at 17:33 -0800, Eric Dumazet wrote:

> Another thing to consider is the default MTU value :
> 
> 65536 for lo, and 1500 for veth
> 
> It easily explains half performance for veth
> 
> One another thing is the tx-nocache-copy setting, this can explain some
> extra percents.

By the way I get crashes when doing :

# ip link add name veth1 type veth peer name veth0
# rmmod veth

I'll submit a patch.
