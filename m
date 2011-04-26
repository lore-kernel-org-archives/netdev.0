From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 v6 5/5] sctp: Add ASCONF operation on the
 single-homed host
Date: Tue, 26 Apr 2011 13:33:42 +0800
Message-ID: <4DB65936.9020906@cn.fujitsu.com>
References: <856CB69B-767A-4F6C-9DBF-26EEAFCC3B56@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61956 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752531Ab1DZFd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 01:33:56 -0400
In-Reply-To: <856CB69B-767A-4F6C-9DBF-26EEAFCC3B56@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> SCTP can change the IP address on the single-homed host.  
> In this case, the SCTP association transmits an ASCONF packet including addition of the new IP address and deletion of the old address.  This patch implements this functionality.  
> In this case, the ASCONF chunk is added to the beginning of the queue, because the other chunks cannot be transmitted in this state.  
>
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> ---
>
Acked-by: Wei Yongjun <yjwei@cn.fujitsu.com>

