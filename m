From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Fix kernel panic while send SCTP data with IP
 fragments
Date: Mon, 20 Aug 2007 11:29:15 +0900 (JST)
Message-ID: <20070820.112915.45451796.yoshfuji@linux-ipv6.org>
References: <46C8EE3B.40105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: yjwei@cn.fujitsu.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55141 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754785AbXHTC2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2007 22:28:08 -0400
In-Reply-To: <46C8EE3B.40105@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <46C8EE3B.40105@cn.fujitsu.com> (at Mon, 20 Aug 2007 09:28:27 +0800), Wei Yongjun <yjwei@cn.fujitsu.com> says:

> If ICMP6 message with "Packet Too Big" is received after send SCTP DATA,
> kernel panic will occur when SCTP DATA is send again.
> 
> This is because of a bad dest address when call to skb_copy_bits().
:
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
