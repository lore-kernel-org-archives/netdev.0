From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 3/8] sctp: use common head of addr
 parameter to access member in addr-unrelated code
Date: Tue, 19 Apr 2011 21:47:17 -0700 (PDT)
Message-ID: <20110419.214717.241907437.davem@davemloft.net>
References: <4DAD18AB.3040401@cn.fujitsu.com>
	<4DAD1993.5070801@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54814
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750869Ab1DTErv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 00:47:51 -0400
In-Reply-To: <4DAD1993.5070801@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 19 Apr 2011 13:11:47 +0800

> From: Shan Wei <shanwei@cn.fujitsu.com>
> 
> The 'p' member of struct sctp_paramhdr is common part for
> IPv4 addr parameter and IPv6 addr parameter in union sctp_addr_param.
> 
> For addr-related code, use specified addr parameter.
> Otherwise, use common header to access type/length member.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
