From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Tue, 13 Jun 2006 08:13:42 -0300
Message-ID: <39e6f6c70606130413g555c501fra845075833c3336b@mail.gmail.com>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com>
	 <20060613140716.6af45bec@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Sridhar Samudrala" <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.232]:35819 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1750949AbWFMLNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 07:13:47 -0400
Received: by wr-out-0506.google.com with SMTP id i24so1363495wra
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2006 04:13:46 -0700 (PDT)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060613140716.6af45bec@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/13/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> On Mon, 12 Jun 2006 16:56:01 -0700
> Sridhar Samudrala <sri@us.ibm.com> wrote:
>
> > This patch makes it convenient to use the sockets API by the in-kernel
> > users like sunrpc, cifs & ocfs2 etc and any future users.
> > Currently they get to this API by directly accesing the function pointers
> > in the sock structure.
> >
> > Most of these functions are pretty simple and can be made inline and moved
> > to linux/net.h.
>
> ...
>
> > @@ -2176,3 +2279,13 @@ EXPORT_SYMBOL(sock_wake_async);
> >  EXPORT_SYMBOL(sockfd_lookup);
> >  EXPORT_SYMBOL(kernel_sendmsg);
> >  EXPORT_SYMBOL(kernel_recvmsg);
> > +EXPORT_SYMBOL(kernel_bind);
> > +EXPORT_SYMBOL(kernel_listen);
> > +EXPORT_SYMBOL(kernel_accept);
> > +EXPORT_SYMBOL(kernel_connect);
> > +EXPORT_SYMBOL(kernel_getsockname);
> > +EXPORT_SYMBOL(kernel_getpeername);
> > +EXPORT_SYMBOL(kernel_getsockopt);
> > +EXPORT_SYMBOL(kernel_setsockopt);
> > +EXPORT_SYMBOL(kernel_sendpage);
> > +EXPORT_SYMBOL(kernel_ioctl);
>
> Don't we want to restrict this to GPL code with EXPORT_SYMBOL_GPL?

I guess so, Sridhar, could you take this into account and resend?

Thanks,

- Arnaldo
