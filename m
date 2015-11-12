From: Oleg A Arkhangelsky <sysoleg@yandex.ru>
Subject: Re: Why my NIC shows NUMA -1?
Date: Thu, 12 Nov 2015 09:21:28 +0300
Message-ID: <1663671447309288@web21m.yandex.ru>
References: <CAK3+h2wTdCVHLpwoKF93aGeKd2MTtgMK2cNstw94a=Fv_94iGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Vincent Li <vincent.mc.li@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward11m.cmail.yandex.net ([5.255.216.137]:39374 "EHLO
	forward11m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750917AbbKLG2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2015 01:28:07 -0500
In-Reply-To: <CAK3+h2wTdCVHLpwoKF93aGeKd2MTtgMK2cNstw94a=Fv_94iGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



12.11.2015, 01:41, "Vincent Li" <vincent.mc.li@gmail.com>:
> Hi
>
> Sorry I am not sure if this is the right list to ask this question,
> please direct me to the correct one. thanks!
>
> I am using Intel 82599 on Dell PowerEdge R710 which should support
> NUMA node, the box is running ubuntu 14.01.1 LTS , I am wondering why=
 I
> get NUMA socket -1.
>
> in BIOS, the memory "Node Interleaving" is
> disabled by default and I am using DPDK and DPDK sees my NIC NUMA -1,
> but i guess it is
> not related to DPDK since the sysfs shows NUMA -1, any clue?

numa_node value is set according to information provided by BIOS _PXM
table.

This can be related to your question:
https://patchwork.ozlabs.org/patch/400073/

--
wbr, Oleg.

"Anarchy is about taking complete responsibility for yourself."
=9A=9A=9A=9A=9A Alan Moore.
