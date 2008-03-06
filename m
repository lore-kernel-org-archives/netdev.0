From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: DoS by cat /proc/net/ip_conntrack ?
Date: Thu, 6 Mar 2008 14:51:11 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0803061449220.23263@bizon.gios.gov.pl>
References: <20080306134037.M70019@visp.net.lb>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1234903137-1204811471=:23263"
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:36059 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757296AbYCFNvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 08:51:16 -0500
In-Reply-To: <20080306134037.M70019@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1234903137-1204811471=:23263
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Thu, 6 Mar 2008, Denys Fedoryshchenko wrote:

> Hi again
Hi,

> On loaded router
> net.netfilter.nf_conntrack_count =3D 415633
> passing about 100-150 Mbps
> network cards 3xe100, 1xe1000e
>
> i tried to issue command cat /proc/net/ip_conntrack |grep 'something'
>
> Router went dead for about 2 minutes, even i disconnect ssh session.
> Ping was looks like this:
> 64 bytes from dotfib (10.184.184.1): icmp_seq=3D15 ttl=3D61 time=3D4321 m=
s
> 64 bytes from dotfib (10.184.184.1): icmp_seq=3D50 ttl=3D61 time=3D398 ms
> 64 bytes from dotfib (10.184.184.1): icmp_seq=3D122 ttl=3D61 time=3D15.3 =
ms
> 64 bytes from dotfib (10.184.184.1): icmp_seq=3D142 ttl=3D61 time=3D4452 =
ms
> 64 bytes from dotfib (10.184.184.1): icmp_seq=3D180 ttl=3D61 time=3D850 m=
s
> (system recovered)
> 64 bytes from dotfib (10.184.184.1): icmp_seq=3D182 ttl=3D61 time=3D0.681=
 ms
> 64 bytes from dotfib (10.184.184.1): icmp_seq=3D183 ttl=3D61 time=3D0.936=
 ms
> 64 bytes from dotfib (10.184.184.1): icmp_seq=3D184 ttl=3D61 time=3D2.94 =
ms
>
> I dont think it is normal, and such command taking a lot of system resour=
ces
> and cause whole system to hang.
>
> Kernel 2.6.24.2

The answer is quite simple here: don't do this. Instead use "conntrack -L"=
=20
as netlink is much more effective and better designed.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1234903137-1204811471=:23263--
