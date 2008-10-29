From: Patrick McHardy <kaber@trash.net>
Subject: Re: atl1 warn_on_slowpath help
Date: Wed, 29 Oct 2008 17:47:49 +0100
Message-ID: <490893B5.6090806@trash.net>
References: <20081029071549.GA4861@ff.dom.local> <49081AE4.9040301@trash.net> <49083825.3000601@trash.net> <3400f2f60810290551y39c61e0aj90ca1222b339798c@mail.gmail.com> <B936998C7BAD4852B0CD9AB17E72CFD0@CTTCA769C54C37>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'J. K. Cliburn'" <jcliburn@gmail.com>,
	'Jarek Poplawski' <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Ramon Casellas <ramon.casellas@cttc.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37816 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066AbYJ2Qrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 12:47:51 -0400
In-Reply-To: <B936998C7BAD4852B0CD9AB17E72CFD0@CTTCA769C54C37>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ramon Casellas wrote:
>> -----Mensaje original-----
>> De: J. K. Cliburn [mailto:jcliburn@gmail.com]
> 
>> Can you please try the attached patch from Patrick and see if it fixes
>> your kernel warning?
> 
> I applied the patch to linux.2.6.27.2 (already patched for VLAN support on
> ATL1 devices as per Jay fix). Patch applied cleanly and there was no warn on
> slow path on dmesg after the reboot, with fully functional VLAN (broken in
> atl cards since 2.6.26)
> 
> Linux failamp 2.6.27.2 #1 SMP Wed Oct 29 14:22:49 CET 2008 i686 GNU/Linux
> 
> 3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state
> UP qlen 1000
>     link/ether 00:1f:c6:bb:75:fa brd ff:ff:ff:ff:ff:ff
>     inet 1.1.1.91/24 brd 1.1.1.255 scope global eth0
>     inet6 fe80::21f:c6ff:febb:75fa/64 scope link 
>        valid_lft forever preferred_lft forever
> 
> 4: eth0.200@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
> state UP 
>     link/ether 00:1f:c6:bb:75:fa brd ff:ff:ff:ff:ff:ff
>     inet 10.1.1.91/24 brd 10.1.1.255 scope global eth0.200
>     inet6 fe80::21f:c6ff:febb:75fa/64 scope link 
>        valid_lft forever preferred_lft forever
> 5: eth0.300@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
> state UP 
>     link/ether 00:1f:c6:bb:75:fa brd ff:ff:ff:ff:ff:ff
>     inet 192.168.100.91/24 brd 192.168.100.255 scope global eth0.300
>     inet6 fe80::21f:c6ff:febb:75fa/64 scope link 
>        valid_lft forever preferred_lft forever
> 
> I played a bit with tshark: 
> 
> failamp:/mnt# tshark -i eth0.300
> Running as user "root" and group "root". This could be dangerous.
> Capturing on eth0.300
>   0.000000 Cisco_35:9a:11 -> PVST+        STP Conf. Root = 
> 33068/00:0e:84:50:ff:80  Cost = 12  Port = 0x8011
> 
> Thanks for your efforts. Let me know if you need further testing.

This seems to be enough, thanks a lot.

