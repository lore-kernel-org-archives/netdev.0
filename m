From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: TCP fragmentation broken in 3.6-rc ?
Date: Mon, 20 Aug 2012 18:02:51 +0200
Message-ID: <1345478571.5158.323.camel@edumazet-glaptop>
References: <CAF6-1L6xy1rRd321ZMzrLG6xHMdO0+sdjbtznUOsMzfYyU1SEg@mail.gmail.com>
	 <CAF6-1L5bnhHfXide-=+4WmskR6xGLg4q+RWHebH+GiX7P-RX+Q@mail.gmail.com>
	 <1345475670.5158.322.camel@edumazet-glaptop>
	 <CAF6-1L7R_N1JkubzLwbv9eVX0F+QTtB5SXaRnXU1vBnb_avSMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sylvain Munaut <s.munaut@whatever-company.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64905 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695Ab2HTQC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 12:02:56 -0400
Received: by bkwj10 with SMTP id j10so1909731bkw.19
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2012 09:02:55 -0700 (PDT)
In-Reply-To: <CAF6-1L7R_N1JkubzLwbv9eVX0F+QTtB5SXaRnXU1vBnb_avSMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-20 at 17:52 +0200, Sylvain Munaut wrote:
> Hi,
> 
> > Could you make sure its not a pfmemalloc problem, by applying following
> > patch :
> >
> > https://lkml.org/lkml/2012/8/20/182
> 
> I just tried it, but unfortunately it doesn't fix the problem :(
> 
> It may have improved a bit (seems like it takes 20/25 min to break now
> ... but it might just be random luck)

OK thanks

Any chance you could post a tcpdump demonstrating the problem ? 
(including the tcp session plus icmp messages)
