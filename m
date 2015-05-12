From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 5/5] net: Add GRE keyid in flow_keys
Date: Tue, 12 May 2015 09:06:17 -0700
Message-ID: <1431446777.566.87.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431401204-731380-1-git-send-email-tom@herbertland.com>
	 <1431401204-731380-6-git-send-email-tom@herbertland.com>
	 <1431405215.566.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431406237.566.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S36nVmVxo2QADh-Qmyk7+TU=Zo4vAmRtU1qtDtRqFWGAJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35974 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932828AbbELQGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 12:06:20 -0400
Received: by pdea3 with SMTP id a3so17880666pde.3
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 09:06:20 -0700 (PDT)
In-Reply-To: <CALx6S36nVmVxo2QADh-Qmyk7+TU=Zo4vAmRtU1qtDtRqFWGAJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-12 at 10:51 -0400, Tom Herbert wrote:

> 
> I don't see these errors with sparse. How are you running it?
> 
> Thanks,
> Tom

root@edumazet-glaptop2:/usr/src/net-next# sparse --version
0.4.5-rc1
root@edumazet-glaptop2:/usr/src/net-next# make C=2 CF=-D__CHECK_ENDIAN__
M=net/ipv4
  CHECK   net/ipv4/route.c
  CHECK   net/ipv4/inetpeer.c
  CHECK   net/ipv4/protocol.c
  CHECK   net/ipv4/ip_input.c
  CHECK   net/ipv4/ip_fragment.c
  CHECK   net/ipv4/ip_forward.c
  CHECK   net/ipv4/ip_options.c
  CHECK   net/ipv4/ip_output.c
...
  CHECK   net/ipv4/tcp_offload.c
net/ipv4/tcp_offload.c:139:60: warning: incorrect type in argument 2
(different base types)
net/ipv4/tcp_offload.c:139:60:    expected restricted __wsum [usertype]
res
net/ipv4/tcp_offload.c:139:60:    got fouled restricted __sum16
include/linux/skbuff.h:3362:14: warning: incorrect type in assignment
(different base types)
include/linux/skbuff.h:3362:14:    expected unsigned short [unsigned]
[usertype] csum
include/linux/skbuff.h:3362:14:    got restricted __sum16
include/linux/skbuff.h:3367:16: warning: incorrect type in return
expression (different base types)
include/linux/skbuff.h:3367:16:    expected restricted __sum16
include/linux/skbuff.h:3367:16:    got unsigned short [unsigned]
[usertype] csum
net/ipv4/tcp_offload.c:173:52: warning: incorrect type in argument 2
(different base types)
net/ipv4/tcp_offload.c:173:52:    expected restricted __wsum [usertype]
res
net/ipv4/tcp_offload.c:173:52:    got fouled restricted __sum16
include/linux/skbuff.h:3362:14: warning: incorrect type in assignment
(different base types)
include/linux/skbuff.h:3362:14:    expected unsigned short [unsigned]
[usertype] csum
include/linux/skbuff.h:3362:14:    got restricted __sum16
include/linux/skbuff.h:3367:16: warning: incorrect type in return
expression (different base types)
include/linux/skbuff.h:3367:16:    expected restricted __sum16
include/linux/skbuff.h:3367:16:    got unsigned short [unsigned]
[usertype] csum
  CHECK   net/ipv4/gre_offload.c
include/linux/skbuff.h:3362:14: warning: incorrect type in assignment
(different base types)
include/linux/skbuff.h:3362:14:    expected unsigned short [unsigned]
[usertype] csum
include/linux/skbuff.h:3362:14:    got restricted __sum16
include/linux/skbuff.h:3367:16: warning: incorrect type in return
expression (different base types)
include/linux/skbuff.h:3367:16:    expected restricted __sum16
include/linux/skbuff.h:3367:16:    got unsigned short [unsigned]
[usertype] csum
