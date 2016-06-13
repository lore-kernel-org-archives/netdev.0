From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/2] ovs/vxlan: fix rtnl notifications on iface
 deletion
Date: Mon, 13 Jun 2016 09:44:59 +0200
Message-ID: <575E647B.5040503@6wind.com>
References: <1465551147-17185-1-git-send-email-nicolas.dichtel@6wind.com>
 <CAOrHB_DCupNkAz+BSaOKKE+KLYhK-hytqW2vEV1yQ-iYr6hakg@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36531 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932165AbcFMHpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 03:45:04 -0400
Received: by mail-wm0-f44.google.com with SMTP id n184so65737439wmn.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 00:45:02 -0700 (PDT)
In-Reply-To: <CAOrHB_DCupNkAz+BSaOKKE+KLYhK-hytqW2vEV1yQ-iYr6hakg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/06/2016 19:50, pravin shelar a =C3=A9crit :
[snip]
> Patch looks good except the error handling code. earlier call to
> vxlan_dev_configure() registers the net-device  and add the device to
> vxlan device list. it needs to be undone before freeing the device.
>=20
Ok, will fix it (and also for GRE).


Thank you,
Nicolas
