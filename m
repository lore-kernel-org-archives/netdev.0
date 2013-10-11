From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] netem: update backlog after drop
Date: Fri, 11 Oct 2013 11:38:11 -0700
Message-ID: <1381516691.4971.112.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131006151533.52988624@nehalam.linuxnetplumber.net>
	 <20131011.143018.1801127237009991334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:46885 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846Ab3JKSiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 14:38:15 -0400
Received: by mail-ob0-f180.google.com with SMTP id wn1so3045136obc.39
        for <netdev@vger.kernel.org>; Fri, 11 Oct 2013 11:38:15 -0700 (PDT)
In-Reply-To: <20131011.143018.1801127237009991334.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-11 at 14:30 -0400, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Sun, 6 Oct 2013 15:15:33 -0700
>=20
> > When packet is dropped from rb-tree netem the backlog statistic sho=
uld
> > also be updated.
> >=20
> > Reported-by: =D0=A1=D0=B5=D1=80=D0=B3=D0=B5=D0=B5=D0=B2 =D0=A1=D0=B5=
=D1=80=D0=B3=D0=B5=D0=B9 <adron@yapic.net>
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> >=20
> > ---
> > Should be reviewed by Eric (he added the rb-tree stuff), and added =
to stable
> > as well.
>=20
> Eric please review this patch, thanks.

It somehow escaped from my radar ;)

Acked-by: Eric Dumazet <edumazet@google.com>
