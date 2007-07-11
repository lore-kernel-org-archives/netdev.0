From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [patch 2/8] Make some network-related proc files use
 seq_list_xxx helpers
Date: Wed, 11 Jul 2007 09:05:13 +0900 (JST)
Message-ID: <200707110005.l6B05ErU005927@toshiba.co.jp>
References: <200707091851.l69IpAma001726@imap1.linux-foundation.org>
	<20070709.131523.93383253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, xemul@sw.ru,
	xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:37418 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763880AbXGKAfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 20:35:22 -0400
Received: from inet-tsb5.toshiba.co.jp (inet-tsb5 [202.33.96.24])
	by imx9.toshiba.co.jp  with ESMTP id l6B0ZIFv013453
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 09:35:19 +0900 (JST)
Received: from tsb-wall.toshiba.co.jp ([133.199.160.134])
	by inet-tsb5.toshiba.co.jp  with ESMTP id l6B05GYJ018368
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 09:05:16 +0900 (JST)
Received: (from root@localhost)
	by tsb-wall.toshiba.co.jp  id l6B05FTc010801
	for netdev@vger.kernel.org; Wed, 11 Jul 2007 09:05:15 +0900 (JST)
Received: from mx.toshiba.co.jp (localhost [127.0.0.1])
	by ovp1.toshiba.co.jp  with ESMTP id l6B05FMQ008240
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 09:05:15 +0900 (JST)
In-Reply-To: <20070709.131523.93383253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I've met compile error on net-2.6.23 tree.

net/built-in.o: In function `proto_seq_next':
sock.c:(.text+0x3008): undefined reference to `seq_list_next'
net/built-in.o: In function `proto_seq_start':
sock.c:(.text+0x3079): undefined reference to `seq_list_start_head'
make: *** [.tmp_vmlinux1] Error 1

-- Yasuyuki Kozakai

From: David Miller <davem@davemloft.net>
Date: Mon, 09 Jul 2007 13:15:23 -0700 (PDT)

> From: akpm@linux-foundation.org
> Date: Mon, 09 Jul 2007 11:51:10 -0700
> 
> > From: Pavel Emelianov <xemul@sw.ru>
> > 
> > This includes /proc/net/protocols, /proc/net/rxrpc_calls and
> > /proc/net/rxrpc_connections files.
> > 
> > All three need seq_list_start_head to show some header.
> > 
> > Signed-off-by: Pavel Emelianov <xemul@openvz.org>
> > Acked-by: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Applied, thanks.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
