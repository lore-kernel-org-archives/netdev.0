From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] libnetlink: check flag NLM_F_DUMP_INTR during
 dumps
Date: Fri, 22 Mar 2013 08:14:56 -0700
Message-ID: <1363965296.4431.69.camel@edumazet-glaptop>
References: <1363963557-3888-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1363964393.4431.66.camel@edumazet-glaptop> <514C72B7.8070804@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:55404 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933510Ab3CVPPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 11:15:00 -0400
Received: by mail-pd0-f176.google.com with SMTP id t12so1639248pdi.21
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 08:14:59 -0700 (PDT)
In-Reply-To: <514C72B7.8070804@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-22 at 16:03 +0100, Nicolas Dichtel wrote:
> Le 22/03/2013 15:59, Eric Dumazet a =C3=A9crit :
> > On Fri, 2013-03-22 at 15:45 +0100, Nicolas Dichtel wrote:
> >> When this flag is set, it means that dump was interrupted and resu=
lt may be
> >> wrong. Ask user to restart.
> >>
> >> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> >
> >
> > Do we have a guarantee this will complete eventually, on some hosts
> > constantly adding removing entries ?
> >
>=20
> No. You mean it will be better to just print a warning and continue t=
he dump?
> --

I would not break the dump, return the indication, so that caller can
chose to restart the loop one or two times.
