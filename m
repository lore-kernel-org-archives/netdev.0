From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net V2] net/mlx5e: Fix del vxlan port command buffer
 memset
Date: Thu, 21 Jul 2016 10:48:11 -0700
Message-ID: <20160721174810.GA92690@ast-mbp.thefacebook.com>
References: <1469050793-29235-1-git-send-email-saeedm@mellanox.com>
 <20160721005350.GB85017@ast-mbp>
 <CALzJLG9a7L+_CYdweAu=z6uA91HHswTCjHBdB81PppKSYD-WcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Matthew Finlay <matt@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:35816 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476AbcGURsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 13:48:19 -0400
Received: by mail-yw0-f195.google.com with SMTP id c13so5979150ywh.2
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 10:48:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALzJLG9a7L+_CYdweAu=z6uA91HHswTCjHBdB81PppKSYD-WcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2016 at 11:08:06AM +0300, Saeed Mahameed wrote:
> On Thu, Jul 21, 2016 at 3:53 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Thu, Jul 21, 2016 at 12:39:53AM +0300, Saeed Mahameed wrote:
> >> memset the command buffers rather than the pointers to them.
> >
> > that is still wrong commit log.
> > This patch makes zero difference to generated code.
> > '&in' is the same as 'in'
> >
> 
> Who said they are not ? There was a mistake in the original log
> message and it was fixed here.
> The patch was made to make the code consistent with other places in
> the code, and i don't see anything wrong with the log message.

the commit log implies that there is a bug. There is none.
old code does 'memset the command buffers'.
'rather than the pointers' is not correct.
