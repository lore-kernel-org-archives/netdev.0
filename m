From: =?UTF-8?Q?J=C3=B6rg_Otte?= <jrg.otte@gmail.com>
Subject: Re: [3.8-rc] regression: NETDEV WATCHDOG: eth0 (r8169): transmit
 queue 0 timed out
Date: Sat, 5 Jan 2013 11:15:27 +0100
Message-ID: <CADDKRnBCrDz2X=5qpGE+r92ZFX5cA+jnSGt3wS8TR0RE8hi1HA@mail.gmail.com>
References: <CADDKRnBqxSwC7HUP_aN1QELrv2+7jnncXj7EP0Pqv8E8FFTpPw@mail.gmail.com>
	<20130105093718.GA938@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:49894 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755401Ab3AEKP2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 05:15:28 -0500
In-Reply-To: <20130105093718.GA938@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/5 Francois Romieu <romieu@fr.zoreil.com>:
> J=C3=B6rg Otte <jrg.otte@gmail.com> :
> [...]
>> It's a regression, it never happend before 3.8-rc.
>
> Please check that 'dmesg | grep XID' exhibits a 8168evl.

jojo@ahorn:~$ dmesg | grep XID
[    1.808847] r8169 0000:02:00.0 eth0: RTL8168evl/8111evl at
0xffffc90000054000, 5c:9a:d8:69:2b:39, XID 0c900800 IRQ 42
jojo@ahorn:~$

>
> I'll showe and dig it. It's epidemic.
>

Thanks, J=C3=B6rg
