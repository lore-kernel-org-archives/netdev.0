From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference BUG in ip_send_skb()
Date: Fri, 10 Aug 2012 18:45:46 +0200
Message-ID: <1344617146.31104.2736.camel@edumazet-glaptop>
References: <20120810163112.GA32544@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Stultz <johnstul@us.ibm.com>,
	Paul Moore <paul@paul-moore.com>,
	Eric Paris <eparis@parisplace.org>,
	"Serge E. Hallyn" <serge@hallyn.com>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58394 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831Ab2HJQpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 12:45:51 -0400
Received: by mail-bk0-f46.google.com with SMTP id j10so672085bkw.19
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 09:45:51 -0700 (PDT)
In-Reply-To: <20120810163112.GA32544@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-08-11 at 00:31 +0800, Fengguang Wu wrote:
> Hi Eric,
> 
> This line triggers a NULL deference since commit 3a7c384 ("ipv4: tcp:
> unicast_sock should not land outside of TCP stack").
> 
>         int ip_send_skb(struct sk_buff *skb)
>         {       
> ==>             struct net *net = sock_net(skb->sk);


Hi Fengguang

Fix was sent some hours ago, on netdev list.

http://patchwork.ozlabs.org/patch/176483/

Thanks
