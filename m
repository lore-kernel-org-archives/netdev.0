From: Cong Wang <amwang@redhat.com>
Subject: Re: [rfc] Remove member .name from struct netpoll
Date: Mon, 04 Jul 2011 10:07:00 +0800
Message-ID: <4E112044.8050904@redhat.com>
References: <1309540071.7277.63.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49078 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751650Ab1GDCHL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jul 2011 22:07:11 -0400
In-Reply-To: <1309540071.7277.63.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2011=E5=B9=B407=E6=9C=8802=E6=97=A5 01:07, Joe Perches =E5=86=
=99=E9=81=93:
> struct netpoll has member .name
>
> struct netpoll {
> 	struct net_device *dev;
> 	char dev_name[IFNAMSIZ];
> 	const char *name;
> [...]
> };
>
> that is set only by netconsole.c
>
> static struct netconsole_target *alloc_param_target(char *target_conf=
ig)
> {
> [...]
> 	nt->np.name =3D "netconsole";
>
> and used only by net/core/netpoll.c to emit "netconsole: " on
> logging messages.
>

Probably this is due to that in history netdump was another user of it.

>
> Are there out of tree users or plans to use "struct netpoll"
> by other modules?
>

AFAIK, netoops will use it too, see
https://lkml.org/lkml/2010/11/2/299

Cc'ing Matt in case I miss something...

Thanks.
