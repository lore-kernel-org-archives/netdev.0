From: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>
Subject: Re: possible recursive locking in udp4_lib_rcv
Date: Fri, 8 Aug 2008 18:08:26 +0300
Message-ID: <20080808150825.GA18199@google.com>
References: <20080807234613.GA9598@google.com> <E1KRSxN-0005Ng-00@gondolin.me.apana.org.au> <20080808143741.GA20777@gondor.apana.org.au> <20080808150108.GA21048@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, haoki@redhat.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:10116 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589AbYHHPIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 11:08:37 -0400
Received: by nf-out-0910.google.com with SMTP id d3so396501nfc.21
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2008 08:08:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080808150108.GA21048@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 08, 2008 at 11:01:08PM +0800, Herbert Xu wrote:
> On Fri, Aug 08, 2008 at 10:37:41PM +0800, Herbert Xu wrote:
> >
> > Never mind, I see the reason why it's there.  What we should do
> > is drop the lock when we hit an encapsulated socket since they
> > don't need it at all.
> 
> Here is the patch:

Nice. Open a bugzilla entry for this?
