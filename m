From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/5] sctp: Avoid memory overflow while FWD-TSN
 chunk is received with bad stream ID
Date: Thu, 25 Dec 2008 16:58:33 -0800 (PST)
Message-ID: <20081225.165833.216057003.davem@davemloft.net>
References: <1229737672-28328-1-git-send-email-vladislav.yasevich@hp.com>
	<1229737672-28328-6-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	yjwei@cn.fujitsu.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58148
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752823AbYLZA6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 19:58:36 -0500
In-Reply-To: <1229737672-28328-6-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 19 Dec 2008 20:47:51 -0500

> If FWD-TSN chunk is received with bad stream ID, the sctp will not do the
> validity check, this may cause memory overflow when overwrite the TSN of
> the stream ID.
> 
> The FORWARD-TSN chunk is like this:
> 
> FORWARD-TSN chunk
>   Type                       = 192
>   Flags                      = 0
>   Length                     = 172
>   NewTSN                     = 99
>   Stream                     = 10000
>   StreamSequence             = 0xFFFF
> 
> This patch fix this problem by discard the chunk if stream ID is not
> less than MIS.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied and queued up for -stable.
