From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net/*: use SLAB_PANIC
Date: Tue, 29 Aug 2006 06:01:57 +0400
Message-ID: <20060829020157.GA5192@martell.zuzino.mipt.ru>
References: <20060826230841.GA5204@martell.zuzino.mipt.ru> <20060828093651.GA31341@infradead.org> <20060828.133637.107685776.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:40711 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932081AbWH2CCh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 22:02:37 -0400
Received: by nf-out-0910.google.com with SMTP id x30so80902nfb
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 19:02:31 -0700 (PDT)
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060828.133637.107685776.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2006 at 01:36:37PM -0700, David Miller wrote:
> > ipv6 can be modular, so panicing on a initialization failure is wrong.
>
> That may be the case, but he merely translated the code
> as it existed, he didn't change it to start panic()'ing
> it already did.
>
> It would be a seperate change to undo the panic() in
> the ipv6 code.

That separate change transformed into big cleanup of IPV6 init/exit
codepaths to fix panic properly. Will be posted soon.

