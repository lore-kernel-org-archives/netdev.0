From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@wide.ad.jp>
Subject: Re: [PATCH net-2.6] [IPV6] MIP6: Ensure independence from
 alignment.
Date: Mon, 14 Apr 2008 14:38:32 +0900 (JST)
Message-ID: <20080414.143832.10983998.yoshfuji@wide.ad.jp>
References: <20080409.004632.68333196.yoshfuji@linux-ipv6.org>
	<20080413.222629.180789339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@wide.ad.jp
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33472 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645AbYDNFgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 01:36:49 -0400
In-Reply-To: <20080413.222629.180789339.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080413.222629.180789339.davem@davemloft.net> (at Sun, 13 Apr 2008 22:26:29 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Wed, 09 Apr 2008 00:46:32 +0900 (JST)
> 
> > We cannot rely on sizeof(struct ipv6_opt_hdr) when we are handling
> > wire format, because it may not be 2 but 4 on some architectures.
> > On such a architecture, the result can be different from what we
> > actually expect.
> > 
> > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Please just mark the structure with "packed" attribute.

Sure!

--yoshfuji
