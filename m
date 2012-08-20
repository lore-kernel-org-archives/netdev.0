From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: Fwd: TCP fragmentation broken in 3.6-rc ?
Date: Mon, 20 Aug 2012 17:52:34 +0200
Message-ID: <CAF6-1L7R_N1JkubzLwbv9eVX0F+QTtB5SXaRnXU1vBnb_avSMg@mail.gmail.com>
References: <CAF6-1L6xy1rRd321ZMzrLG6xHMdO0+sdjbtznUOsMzfYyU1SEg@mail.gmail.com>
	<CAF6-1L5bnhHfXide-=+4WmskR6xGLg4q+RWHebH+GiX7P-RX+Q@mail.gmail.com>
	<1345475670.5158.322.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:40832 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221Ab2HTPwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 11:52:35 -0400
Received: by vbbff1 with SMTP id ff1so5450739vbb.19
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2012 08:52:34 -0700 (PDT)
In-Reply-To: <1345475670.5158.322.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Could you make sure its not a pfmemalloc problem, by applying following
> patch :
>
> https://lkml.org/lkml/2012/8/20/182

I just tried it, but unfortunately it doesn't fix the problem :(

It may have improved a bit (seems like it takes 20/25 min to break now
... but it might just be random luck)


Cheers,

    Sylvain
