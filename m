From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink stats:   Ability to get stats for a single device?
Date: Tue, 26 Oct 2010 21:35:20 +0200
Message-ID: <1288121720.2652.15.camel@edumazet-laptop>
References: <4CC72C80.9010802@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62259 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050Ab0JZTfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 15:35:25 -0400
Received: by wwe15 with SMTP id 15so5109022wwe.1
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 12:35:24 -0700 (PDT)
In-Reply-To: <4CC72C80.9010802@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 12:31 -0700, Ben Greear a =C3=A9crit :
> From what I can tell, it's impossible to request stats for a single
> network device via netlink.  When you have thousands of interfaces,
> this means a lot of wasted effort to get stats for a particular
> device.
>=20
> Am I missing something, or do I just need to write up a patch
> to have netlink pay attention to the ifindex?
>=20

Its already done

rtnl_register(PF_UNSPEC, RTM_GETLINK, rtnl_getlink, rtnl_dump_ifinfo);=20



