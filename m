From: "pupilla@libero.it" <pupilla@libero.it>
Subject: ip route add give rtnetlink message after update from 4.9.6 to
 4.9.8
Date: Wed, 8 Feb 2017 11:17:48 +0100 (CET)
Message-ID: <224940468.86611486549068694.JavaMail.httpd@webmail-37.iol.local>
Reply-To: "pupilla@libero.it" <pupilla@libero.it>
Mime-Version: 1.0
Content-Type: text/plain;charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-16.italiaonline.it ([212.48.25.144]:38828 "EHLO libero.it"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753940AbdBHKXE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 05:23:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Folks,

After kernel update from 4.9.6 to 4.9.8, I get the below error
message when I run this command:

root@Typhoon:~# ip route add default table 210 nexthop dev eth0 via 10.68.64.1 
weight 1 nexthop dev eth0 via 10.68.64.2 weight 1
RTNETLINK answers: Operation not supported
root@Typhoon:~# uname -a
Linux Typhoon 4.9.8 #1 SMP Tue Feb 7 17:14:54 CET 2017 x86_64 Intel(R) Core
(TM) i5-2520M CPU @ 2.50GHz GenuineIntel GNU/Linux

Is this the expected behaviour?

Any response are welcome
TIA

Marco
