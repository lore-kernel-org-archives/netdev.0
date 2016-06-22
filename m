From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Regarding VRF support in Linux Kernel
Date: Wed, 22 Jun 2016 14:05:10 -0700
Message-ID: <CADAe=++ATxxEeKiUC6MUSCmXiauvB=6ZFCuuwd2h6ZOQU99p5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:34325 "EHLO
	mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbcFVVFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 17:05:51 -0400
Received: by mail-vk0-f47.google.com with SMTP id c2so48785328vkg.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 14:05:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am following the steps present in
(https://www.kernel.org/doc/Documentation/networking/vrf.txt) and
trying to create IPv4 VRF in latest Fedora 24 distribution with 4.5
Linux kernel.

[root@localhost ip]# uname -a
Linux localhost.localdomain 4.5.5-300.fc24.x86_64 #1 SMP Thu May 19
13:05:32 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

I am getting operation not supported error as shown below

# ip link add vrf-blue type vrf table 10
RTNETLINK answers: Operation not supported

Is there any CONFIG option to enable VRF in Linux kernel ?

Regards,
Ajith
