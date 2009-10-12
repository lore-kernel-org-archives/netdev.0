From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RESEND PATCH net-next-2.6 3/3] ipv6 sit: Set relay to 0.0.0.0
	directly if relay_prefixlen == 0.
Date: Mon, 12 Oct 2009 18:03:19 +0900
Message-ID: <1255338199.2878.16.camel@cirrhata.linux-ipv6.org>
References: <4AD1E169.6090705@linux-ipv6.org> <4AD2DB99.3070208@gmail.com>
	 <20091012.011802.119775755.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:54751 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754755AbZJLJFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 05:05:11 -0400
In-Reply-To: <20091012.011802.119775755.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 12 Oct 2009 09:32:41 +0200
> 
> > Sorry I dont get it
> > 
> > u32 val = any_value ;
> > u32 relay_prefix = val & htonl(0xffffffffUL << 32) should give 0
> > 
> > If not, something is broken and should be fixed.
> 
> Indeed, it's "x >> 32" which is undefined and has to be done as
> something like "(x >> 31) >> 1" when performed on a u32 object.
> 
> Yoshfuji is this patch really necessary?

Well, yes.
6rd allows 32 bit suffix (0 bit prefix).

--yoshfuji

