From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net] sock: ignore SCM_RIGHTS and SCM_CREDENTIALS in __sock_cmsg_send
Date: Mon, 11 Jul 2016 16:52:16 -0400
Message-ID: <CACSApvaVnfA3ay3s=kbW6rcJ3gU4dzgf=1W=q6taf=RDLkbB2g@mail.gmail.com>
References: <1468169506-27038-1-git-send-email-soheil.kdev@gmail.com> <20160711.133946.466146893193258126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Sergei Trofimovich <slyfox@gentoo.org>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35641 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753599AbcGKUw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 16:52:56 -0400
Received: by mail-oi0-f44.google.com with SMTP id r2so165693141oih.2
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 13:52:56 -0700 (PDT)
In-Reply-To: <20160711.133946.466146893193258126.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 4:39 PM, David Miller <davem@davemloft.net> wrote:
>
> From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
> Date: Sun, 10 Jul 2016 12:51:46 -0400
>
> > From: Soheil Hassas Yeganeh <soheil@google.com>
> >
> > Sergei Trofimovich reported that pulse audio sends SCM_CREDENTIALS
> > as a control message to TCP. Since __sock_cmsg_send does not
> > support SCM_RIGHTS and SCM_CREDENTIALS, it returns an error and
> > hence breaks pulse audio over TCP.
> >
> > SCM_RIGHTS and SCM_CREDENTIALS are sent on the SOL_SOCKET layer
> > but they semantically belong to SOL_UNIX. Since all
> > cmsg-processing functions including sock_cmsg_send ignore control
> > messages of other layers, it is best to ignore SCM_RIGHTS
> > and SCM_CREDENTIALS for consistency (and also for fixing pulse
> > audio over TCP).
> >
> > Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> > Reported-by: Sergei Trofimovich <slyfox@gentoo.org>
> > Tested-by: Sergei Trofimovich <slyfox@gentoo.org>
>
> Please resubmit this with a proper "Fixes: " tag which tells which
> commit introduced this regression.

Sorry David that I forgot the Fixes tag. I just updated the patch and
resubmitted.

Thanks!
Soheil
