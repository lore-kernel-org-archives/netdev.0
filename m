From: Jeff Garzik <jgarzik@pobox.com>
Subject: Badness in dst_release (continuing saga)
Date: Mon, 27 Dec 2004 05:04:13 -0500
Message-ID: <41CFDE1D.6000802@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
 <yoshfuji@linux-ipv6.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, it's happened again.  x86 SMP, 2.6.10-rc3-bk9.

I have left the machine up without rebooting, those with accounts may 
ssh in.  First message occurs on Dec 24 in /var/log/messages.1, and they 
continue in /var/log/messages and dmesg.  ssh to gw.yyz.us.

NOTE: it would be wise to "ssh -4" to avoid continuing log spam, when 
you ssh into the box.

	Jeff


Badness in dst_release at include/net/dst.h:149
  [<f8c1124d>] ip6_dst_check+0x64/0x6a [ipv6]
  [<f8c080da>] ip6_dst_lookup+0x1a7/0x1c1 [ipv6]
  [<f8c1a4da>] udpv6_sendmsg+0x297/0x931 [ipv6]
  [<c031955f>] udp_recvmsg+0x60/0x2e9
  [<c03208dd>] inet_sendmsg+0x4d/0x59
  [<c02d3428>] sock_sendmsg+0xe8/0x103
  [<c011bb37>] find_busiest_group+0xcf/0x2db
  [<c011bfb9>] load_balance_newidle+0x36/0xb4
  [<c01ec0b8>] copy_from_user+0x42/0x6e
  [<c0133e46>] autoremove_wake_function+0x0/0x57
  [<c02d4d46>] sys_sendmsg+0x189/0x1e6
  [<c011c826>] __wake_up_common+0x3f/0x5e
  [<c011c885>] __wake_up+0x40/0x56
  [<c01344b5>] wake_futex+0x37/0x62
  [<c0134554>] futex_wake+0x74/0xc4
  [<c01ec0b8>] copy_from_user+0x42/0x6e
  [<c02d51d0>] sys_socketcall+0x236/0x254
  [<c0102f0d>] sysenter_past_esp+0x52/0x75
