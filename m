From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: Fix protocol violation When receiving an error
 lenght INIT-ACK
Date: Fri, 28 Mar 2008 09:35:37 -0400
Message-ID: <47ECF429.6050308@hp.com>
References: <47EC46D3.3010105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	lksctp-dev <lksctp-developers@lists.sourceforge.net>
To: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:35073 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173AbYC1Nfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 09:35:39 -0400
In-Reply-To: <47EC46D3.3010105@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gui Jianfeng wrote:
> When receiving an error length INIT-ACK during COOKIE-WAIT,
> a 0-vtag ABORT will be responsed. This action violates the
> protocol apparently. This patch achieves the following things.
> 1 If the INIT-ACK contains all the fixed parameters, use init-tag
>   recorded from INIT-ACK as vtag.
> 2 If the INIT-ACK doesn't contain all the fixed parameters,
>   just reflect its vtag.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
> ---

I applied this although there we witespace errors (which I fixed up).
I'll push this to David shortly.

-vlad
