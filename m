From: Jeff Garzik <jgarzik@pobox.com>
Subject: IPv6 badness continues
Date: Tue, 04 Jan 2005 01:40:32 -0500
Message-ID: <41DA3A60.8050102@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
 <yoshfuji@linux-ipv6.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This problem seems to be appearing much sooner, in 2.6.10 and 2.6.10-bk 
kernels.  Herbert, your patch did not apply to recent kernels, so I did 
not boot with it.

The first 'Badness in dst_release' message (of many) from 2.6.10-bk1, on 
x86 SMP, is found below.

Standard FC2 OS with IPv6 6to4 setup as described on 
http://linux.yyz.us/ipv6-fc2-howto.html

Sorry, this is my main fileserver and router, so I need to reboot it...

	Jeff


Badness in dst_release at include/net/dst.h:149
  [<f8c14a57>] ip6_dst_check+0x67/0x80 [ipv6]
  [<f8c0b2d4>] ip6_dst_lookup+0x1b4/0x1d0 [ipv6]
  [<f8c1e4b4>] udpv6_sendmsg+0x2b4/0x950 [ipv6]
  [<c0337954>] udp_recvmsg+0x64/0x300
  [<c033f12d>] inet_sendmsg+0x4d/0x60
  [<c02ed4bd>] sock_sendmsg+0xdd/0x100
  [<c011d694>] find_busiest_group+0xd4/0x300
  [<c01fa662>] copy_from_user+0x42/0x70
  [<c01371a0>] autoremove_wake_function+0x0/0x60
  [<c02eef5f>] sys_sendmsg+0x18f/0x1f0
  [<c011e431>] __wake_up_common+0x41/0x70
  [<c011e49e>] __wake_up+0x3e/0x60
  [<c0137877>] wake_futex+0x37/0x70
  [<c013792b>] futex_wake+0x7b/0xd0
  [<c01fa662>] copy_from_user+0x42/0x70
  [<c02ef402>] sys_socketcall+0x242/0x260
