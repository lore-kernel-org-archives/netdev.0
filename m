From: =?UTF-8?B?QWxleCBWaWxsYWPDrcKtcyBMYXNzbw==?=
	<a_villacis@palosanto.com>
Subject: Re: Fwd: Re: WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x277/0x280()
Date: Fri, 04 May 2012 09:57:13 -0500
Message-ID: <4FA3EE49.7070805@palosanto.com>
References: <20120503064726.GA17337@electric-eye.fr.zoreil.com> <4FA2A6A4.1030308@ceibo.fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.palosanto.com ([200.93.199.101]:39541 "EHLO
	pbx.palosanto.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000Ab2EDO5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 10:57:15 -0400
In-Reply-To: <4FA2A6A4.1030308@ceibo.fiec.espol.edu.ec>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Resending to netdev@vger.kernel.org since previous attempt was rejecte=
d as spam)

El 03/05/12 10:39, Alex Villac=C3=AD=C2=ADs Lasso escribi=C3=B3:
> Alex Villac=C3=AD=C2=ADs Lasso<avillaci@fiec.espol.edu.ec>  :
> [...]
> >  I am currently away from the target computer. How should I check f=
or this? lspci?
>
> lspci can not tell much. Use 'dmesg | grep XID' instead.
[alex@karlalex linux-git]$ dmesg | grep -i xid
[   10.647557] r8169 0000:02:00.0: eth0: RTL8168b/8111b at 0xffffc90000=
352000, 00:22:68:44:17:2f, XID 98500000 IRQ 43
> A complete dmesg would be welcome.
>
> It could help to know a few things :
> - does the problem qualify as a regression since some kernel version =
?
>    If so which one ?
I have only seen these messages since 3.4-rc1. Vanilla kernels up to 3.=
3, and stock Fedora 16 kernels (kernel-3.3.2-6.fc16.x86_64) did not dis=
play this problem. However, I cannot confirm that the latest stock kern=
el is free from the message, since I prefer=20
to run the latest RC kernel on my home machine.
> - can it be reproduced with a kernel that has not been vbox tainted ?
I will check this. However, since the message only appears after an hou=
r of so of moderate bittorrent traffic, it might take a while to confir=
m.
> - does networking recover ?
It does recover, after a few seconds.
>
> Thanks.
>
> --=20
> Ueimor
>
