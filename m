From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] INET: fix incorrect "inet_sock->is_icsk" assignment
Date: Mon, 8 Jan 2007 09:47:29 -0500
Message-ID: <200701080947.29270.paul.moore@hp.com>
References: <20070108132548.GA2324@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:41810 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751564AbXAHOrf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 09:47:35 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20070108132548.GA2324@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, January 8 2007 8:25 am, Jarek Poplawski wrote:
> On 04-01-2007 21:04, Paul Moore wrote:
> > +++ net-2.6.20_bugfix_2/net/ipv4/af_inet.c
> > @@ -305,7 +305,7 @@ lookup_protocol:
> >  		sk->sk_reuse = 1;
> >
> >  	inet = inet_sk(sk);
> > -	inet->is_icsk = INET_PROTOSW_ICSK & answer_flags;
> > +	inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) ==
> > INET_PROTOSW_ICSK;
>
> Isn't this more readable like this?:
>
> inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) != 0;

I guess it all depends on who is reading it ;)  Personally, I don't care too 
much either way as long as it is fixed.

-- 
paul moore
linux security @ hp
