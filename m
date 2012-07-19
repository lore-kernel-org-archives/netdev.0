From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: tcp: remove per net tcp_sock
Date: Thu, 19 Jul 2012 19:08:34 +0200
Message-ID: <1342717714.2626.4495.camel@edumazet-glaptop>
References: <1342688332.2626.4001.camel@edumazet-glaptop>
	 <20120719.083544.1223522161508413373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, wsommerfeld@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:57147 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300Ab2GSRIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:08:40 -0400
Received: by vbbff1 with SMTP id ff1so2143259vbb.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 10:08:39 -0700 (PDT)
In-Reply-To: <20120719.083544.1223522161508413373.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 08:35 -0700, David Miller wrote:

> > @@ -2624,13 +2624,11 @@ EXPORT_SYMBOL(tcp_prot);
> >  
> >  static int __net_init tcp_sk_init(struct net *net)
> >  {
> > -	return inet_ctl_sock_create(&net->ipv4.tcp_sock,
> > -				    PF_INET, SOCK_RAW, IPPROTO_TCP, net);
> > +	return 0;
> >  }
> >  
> >  static void __net_exit tcp_sk_exit(struct net *net)
> >  {
> > -	inet_ctl_sock_destroy(net->ipv4.tcp_sock);
> >  }
> >  
> >  static void __net_exit tcp_sk_exit_batch(struct list_head *net_exit_list)
> 
> If these no longer really do anything, just send me a patch to kill
> them off entirely.
> 

We cant remove them, because of tcp_sk_exit_batch()
