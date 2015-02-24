From: Michael Kazakov <michael@marathonbet.ru>
Subject: Packet dropps in virtual tap interface
Date: Tue, 24 Feb 2015 10:18:59 +0300
Message-ID: <54EC25E3.5050602@marathonbet.ru>
References: <54EC24FF.3000407@marathonbet.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.marathonbet.ru ([194.9.2.180]:42427 "EHLO
	mx0.marathonbet.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbbBXHYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 02:24:30 -0500
Received: from [10.0.3.109] (kazakov.mara.local [10.0.3.109])
	by mx0.marathonbet.ru (Postfix) with ESMTP id D9E7B60271
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 10:18:59 +0300 (MSK)
In-Reply-To: <54EC24FF.3000407@marathonbet.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hello. We use our highly load system in OpenStack environment. And face=
d
with serious problems in network highload guests. At a relatively high
CPU load of hypervisor (40-60%) virtual network interfaces of this
guests starts to droppart of the packets. We use for virtualization
qemu-kvm with vhost driver: "... -netdev
tap,fd=3D30,id=3Dhostnet0,vhost=3Don,vhostfd=3D31 -device
virtio-net-pci,netdev=3Dhostnet0,id=3Dnet0,mac=3Dfa:16:3e:86:67:7b,bus=3D=
pci.0,addr=3D0x3...".

The problem can be seen with the ifconfig utility:
tape4009073-0b Link encap:Ethernet  HWaddr fe:16:3e:86:67:7b
           inet6 addr: fe80::fc16:3eff:fe86:677b/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:1587622634 errors:0 dropped:0 overruns:0 frame:0
           TX packets:1484106438 errors:0 dropped:460259 overruns:0
carrier:0
           collisions:0 txqueuelen:500
           RX bytes:877878711500 (877.8 GB)  TX bytes:3071846828531 (3.=
0
TB)

Could you do a little look at our problem and give advice which
direction to continue our investigation?



--=20
=D0=A1 =D1=83=D0=B2=D0=B0=D0=B6=D0=B5=D0=BD=D0=B8=D0=B5=D0=BC,
=D0=9C=D0=B8=D1=85=D0=B0=D0=B8=D0=BB =D0=9A=D0=B0=D0=B7=D0=B0=D0=BA=D0=BE=
=D0=B2
=D0=A1=D1=82=D0=B0=D1=80=D1=88=D0=B8=D0=B9 =D1=81=D0=B8=D1=81=D1=82=D0=B5=
=D0=BC=D0=BD=D1=8B=D0=B9 =D0=B0=D0=B4=D0=BC=D0=B8=D0=BD=D0=B8=D1=81=D1=82=
=D1=80=D0=B0=D1=82=D0=BE=D1=80
OOO "=D0=A1=D0=9F=D0=9B=D0=90=D0=A2"
