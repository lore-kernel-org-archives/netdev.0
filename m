From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/3] Various tcp_probe module improvements
Date: Wed, 21 Aug 2013 19:47:57 +0200
Message-ID: <1377107280-31091-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17885 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726Ab3HURsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 13:48:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Future follow-up work could include a small, generic user space helper
utility for iproute2's misc folder that would add a top-like display of
both, TCP and SCTP's kprobe-based snoop modules.

Daniel Borkmann (3):
  net: tcp_probe: also include rcv_wnd next to snd_wnd
  net: tcp_probe: kprobes: adapt jtcp_rcv_established signature
  net: tcp_probe: add IPv6 support

 net/ipv4/tcp_probe.c |   67 +++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 55 insertions(+), 12 deletions(-)
