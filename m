From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next-2.6] net: introduce ethernet teaming device
Date: Tue, 04 Oct 2011 17:18:23 +0200
Message-ID: <1317741503.24651.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1317737703-19457-1-git-send-email-jpirko@redhat.com>
	 <1317741242.24651.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59672 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932513Ab1JDPSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 11:18:11 -0400
Received: by bkbzt4 with SMTP id zt4so877000bkb.19
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2011 08:18:09 -0700 (PDT)
In-Reply-To: <1317741242.24651.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 octobre 2011 =C3=A0 17:14 +0200, Eric Dumazet a =C3=A9crit =
:
> Le mardi 04 octobre 2011 =C3=A0 16:15 +0200, Jiri Pirko a =C3=A9crit =
:
> > This patch introduces new network device called team. It supposes t=
o be
> > very fast, simple, userspace-driven alternative to existing bonding
> > driver.
> >=20
> > Userspace library called libteam with couple of demo apps is availa=
ble
> > here:
> > https://github.com/jpirko/libteam
> > Note it's still in its dipers atm.
> >=20
> > team<->libteam use generic netlink for communication. That and rtnl
> > suppose to be the only way to configure team device, no sysfs etc.
> >=20
> > In near future python binding for libteam will be introduced. Also
> > daemon providing arpmon/miimon active-backup functionality will
> > be introduced. All what's necessary is already implemented in kerne=
l team
> > driver.
> >=20
> > Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> > ---
>=20
> Very nice work Jiri

Sorry for the very long answer, I accidentally pressed the "Envoyer"
button before cutting out large part of your mail.
