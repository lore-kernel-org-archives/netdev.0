From: Joe M <joe9mail@gmail.com>
Subject: loading ip_vti breaks IPSec connection
Date: Fri, 12 Sep 2014 22:39:12 -0500
Message-ID: <CAHjjW16qJgU+cf2-fowyJMRioc61Ko8KF65Qp5Npw9DsoF95VA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, christophe.gouault@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:49964 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbaIMDjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 23:39:13 -0400
Received: by mail-qc0-f181.google.com with SMTP id r5so1716553qcx.40
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 20:39:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am not sure what I am missing. When I load ip_vti and ip_tunnel
modules, my IPSec connection stops working.

uname -a
Linux master 3.16.2 #86 SMP PREEMPT Fri Sep 12 22:09:11 CDT 2014
x86_64 Intel(R) Pentium(R) CPU G620 @ 2.60GHz GenuineIntel GNU/Linux

- (0:c:/tmp)  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
sudo modprobe ip_vti ip_tunnel
- (0:c:/tmp)  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
ping -c 1 -I 192.168.0.11 192.168.1.232
PING 192.168.1.232 (192.168.1.232) from 192.168.0.11 : 56(84) bytes of data.

--- 192.168.1.232 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms

- (0:c:/tmp)  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
sudo modprobe --force --remove ip_vti ip_tunnel
- (0:c:/tmp)  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
ping -c 1 -I 192.168.0.11 192.168.1.232
PING 192.168.1.232 (192.168.1.232) from 192.168.0.11 : 56(84) bytes of data.
64 bytes from 192.168.1.232: icmp_seq=1 ttl=64 time=273 ms

--- 192.168.1.232 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 273.347/273.347/273.347/0.000 ms
- (0:i:/tmp)  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

Please note that the module was just loaded without any tunnel
configuration. I am not sure

I am using StrongSwan for IPSec configuration and noticed the same
behaviour with libreswan too.

Please let me know if I can provide more details.

Thanks
Joe
