From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Vlan communication
Date: Tue, 16 Nov 2010 08:52:15 +0100
Message-ID: <1289893935.3364.255.camel@edumazet-laptop>
References: <1289978124.3250.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: kianyang@agroup.com.my
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58339 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759013Ab0KPHwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 02:52:24 -0500
Received: by wyb28 with SMTP id 28so398200wyb.19
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 23:52:23 -0800 (PST)
In-Reply-To: <1289978124.3250.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 novembre 2010 =C3=A0 15:15 +0800, Liew Kian Yang a =C3=A9=
crit :
> Dear All,
>=20
> Can I know is there any ways to make the vlan 1 interface able to sen=
d
> and receive data from the other vlan without using the vconfig to add
> the vlan in linux?

I dont understand your question.

If your problem is vconfig being not available, the answer is

ip link add link eth0 eth0.1 type vlan id 1



