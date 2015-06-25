From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 resend] Fix changing tunnel remote and local
 address to any
Date: Thu, 25 Jun 2015 08:46:16 -0400
Message-ID: <20150625084616.226471e2@uryu.home.lan>
References: <20150604120117.GB7119@indiana.gru.redhat.com>
	<557557A7.5010004@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:33074 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbbFYMqT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 08:46:19 -0400
Received: by ieqy10 with SMTP id y10so53588738ieq.0
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 05:46:19 -0700 (PDT)
In-Reply-To: <557557A7.5010004@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 08 Jun 2015 10:51:51 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Le 04/06/2015 14:01, Thadeu Lima de Souza Cascardo a =C3=A9crit :
> > If a tunnel is created with a local address, you can't change it to=
 any.
> >
> >   # ip tunnel add tunl1 mode ipip remote 10.16.42.37 local 10.16.42=
=2E214 ttl 64
> >   # ip tunnel show tunl1
> >   tunl1: ip/ip  remote 10.16.42.37  local 10.16.42.214  ttl 64
> >   # ip tunnel change tunl1 local any
> >   # echo $?
> >   0
> >   # ip tunnel show tunl1
> >   tunl1: ip/ip  remote 10.16.42.37  local 10.16.42.214  ttl 64
> >
> > It happens that parse_args zeroes ip_tunnel_parm, and when creating=
 the
> > tunnel, it is OK to leave it as is if the address is any. However, =
when
> > changing the tunnel, the current parameters will be read from
> > ip_tunnel_parm, and local and remote address won't be zeroes anymor=
e, so
> > it needs to be explicitly set to any.
> >
> > Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
