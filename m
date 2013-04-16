From: Alex Stahl <testcore@gmail.com>
Subject: How to file a bug against iproute2?
Date: Tue, 16 Apr 2013 12:05:13 -0700
Message-ID: <CAAc8SH5MjWdcFbkmV5uJgUv7nr_PN8n99azV4ZKxL3EKJ9Vthg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:48419 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837Ab3DPTFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 15:05:13 -0400
Received: by mail-ie0-f172.google.com with SMTP id c10so983385ieb.3
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 12:05:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Folks - Apologies in advance if this is the wrong forum for this...
I'd like to file a bug against iproute2 related to a permissions
issue, but can't find the bug tracker.

What I'm observing is that when I've added a user to the 'network'
group, that user is not actually granted permissions to manipulate
network interfaces, at least not through 'ip':

[6@11:56:05 testcore@tc-slim]:~>groups
network users vboxusers wireshark testcore rvm

[7@11:56:06 testcore@tc-slim]:~>ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP mode DEFAULT qlen 1000
    link/ether 4c:72:b9:6e:1b:e8 brd ff:ff:ff:ff:ff:ff
3: wlp2s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
DEFAULT qlen 1000
    link/ether 58:91:cf:54:4f:07 brd ff:ff:ff:ff:ff:ff

[8@11:56:15 testcore@tc-slim]:~>ip link set wlp2s0 up
RTNETLINK answers: Operation not permitted
code 2


I'm using arch linux w/ the latest kernel:

[9@11:56:23 testcore@tc-slim]:~>uname -a
Linux tc-slim 3.8.7-1-ARCH #1 SMP PREEMPT Sat Apr 13 09:01:47 CEST
2013 x86_64 GNU/Linux


According to the arch wiki, if I'm in the 'network' group I should be
able to manipulate interfaces:

https://wiki.archlinux.org/index.php/Groups#Group_list


If anyone has any suggestions on either how to fix this or where to
log it, that would be much appreciated.

Thanks,
Alex
