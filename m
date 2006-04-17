From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: fixing sk_stream_rfree()
Date: Mon, 17 Apr 2006 13:27:36 -0700
Message-ID: <4807377b0604171327m50c9302fv5e636b8aead2e24@mail.gmail.com>
References: <20060414.205927.13626300.davem@davemloft.net>
	 <20060416111831.GA15093@gondor.apana.org.au>
	 <20060416.223203.47773632.davem@davemloft.net>
	 <20060417061700.GA21709@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xproxy.gmail.com ([66.249.82.193]:36109 "EHLO xproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1750943AbWDQU1t convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 16:27:49 -0400
Received: by xproxy.gmail.com with SMTP id t10so400216wxc
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2006 13:27:48 -0700 (PDT)
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060417061700.GA21709@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/16/06, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Sun, Apr 16, 2006 at 10:32:03PM -0700, David S. Miller wrote:
> >
> > Let me save you some time, later in the thread you'll find
> > out that this whole thing is a dead end.
>
> Thanks.  I even read the message but managed to miss your conclusion :)
>
> > So it nearly has to be a send side issue that can only trigger with
> > TSO enabled, and my next planned chore is to audit the TSO splitting
> > during ACK processing.  We may be doing something stupid there.
>
> BTW, do we have a dmesg log from the machine that did this with tg3?

Unfortunately doesn't seem to be any difference between the failures. 
Here were the lines:
2.6.16 kernel

KERNEL: assertion (!sk->sk_forward_alloc) failed at /net/core/stream.c (283)
KERNEL: assertion (!sk->sk_forward_alloc) failed at /net/ipv4/af_inet.c (150)

I'll be glad to test anything to help nail this down.  Herbert did you
see that we used tbench (from dbench package) to reproduce this
reliably?

Jesse
