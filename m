From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [PATCH] move skb->dev assignment into netdev_alloc_skb
Date: Mon, 7 Aug 2006 17:29:54 -0700
Message-ID: <4807377b0608071729p3c744d1fn6859178874019418@mail.gmail.com>
References: <20060805130109.GB24121@lst.de>
	 <20060807.161056.85410448.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hch@lst.de, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:5710 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932455AbWHHA34 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 20:29:56 -0400
Received: by nf-out-0910.google.com with SMTP id x37so27623nfc
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2006 17:29:55 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060807.161056.85410448.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/7/06, David Miller <davem@davemloft.net> wrote:
> From: Christoph Hellwig <hch@lst.de>
> Date: Sat, 5 Aug 2006 15:01:09 +0200
>
> > All caller of netdev_alloc_skb need to assign skb->dev shortly
> > afterwards.  Move it into common code.
> >
> > I also had to fixup a little bit of the surrounding control flow in
> > e1000 - it was just too convoluted.
> >
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
>
> Since the e1000 change is non-trivial I'm not going to bypass
> the driver author on it, sorry.
>
> What I did do was put the netdev_alloc_skb() change into my
> tree, and since I'm co-author of the tg3 driver I'll apply
> that bit too.
>
> The e1000 bit will need to go through the e1000 maintainers.

Thank you, I'll take a look at this tomorrow, as I need to digest the
patch in context.

Jesse
