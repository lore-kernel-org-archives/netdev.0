From: Seblu <seblu@seblu.net>
Subject: Re: Mass udp flow reboot linux with RealTek RTL-8169 Gigabit
Date: Sun, 13 Feb 2011 19:02:38 +0100
Message-ID: <AANLkTikLOJ-XcwfdbWS19DKzh2s91tn5pQjJe0+CeAN-@mail.gmail.com>
References: <AANLkTin7GBSTcfZgr_9sNZ8CPMkW7Vstni+fs2v1-ink@mail.gmail.com>
 <1297581470.2510.18.camel@edumazet-laptop> <20110213135600.GA11382@electric-eye.fr.zoreil.com>
 <AANLkTikTw71-mv9WsPT8PxC1a1nwEJ=x0UNDhVQGP1A6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Ivan Vecera <ivecera@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:45024 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663Ab1BMSDB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 13:03:01 -0500
In-Reply-To: <AANLkTikTw71-mv9WsPT8PxC1a1nwEJ=x0UNDhVQGP1A6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 13, 2011 at 6:27 PM, Seblu <seblu@seblu.net> wrote:
> On Sun, Feb 13, 2011 at 2:56 PM, Francois Romieu <romieu@fr.zoreil.co=
m> wrote:
>> Eric Dumazet <eric.dumazet@gmail.com> :
>> If it still does not perform better, please include the XID line of
>> the r8169 driver from dmesg.
>>
> I've tryed on archlinux i686 distro with 2.6.37 and host reboot like
> under debian.
>
> After this, i tryed =A0wiith a 2.6.38-rc4 (amd64), which include your
> recent patchs.
>
> # dmesg|grep -i xid
> r8169 0000:04:00.0: eth0: RTL8168b/8111b at 0xffffc90005260000,
> 1c:6f:65:56:d9:17, XID 0c200000 IRQ 47
>
> NIC seems to be reset frequently but host stop rebooting. \o//
ok after about 1 hour of iperf, host reboot.

--=20
S=E9bastien Luttringer
www.seblu.net
