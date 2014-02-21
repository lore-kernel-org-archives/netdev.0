From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net v2] net: sctp: rework multihoming retransmission path
 selection to rfc4960
Date: Fri, 21 Feb 2014 15:45:48 -0500
Message-ID: <5307BAFC.8040809@gmail.com>
References: <1392925866-11084-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:58317 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbaBUUpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 15:45:52 -0500
In-Reply-To: <1392925866-11084-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2014 02:51 PM, Daniel Borkmann wrote:
>
> This patch mostly reverts 4141ddc02a92, but also rewrites
> this function to introduce more clarity and strictness into
> the code. A strict priority of transport states is enforced
> in this patch, hence selection is active > unkown > partial
> failover > inactive.
>
> Fixes: 4141ddc02a92 ("sctp: retran_path update bug fix")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Gui Jianfeng <guijianfeng@cn.fujitsu.com>

Acked-by: Vlad Yasevich <yasevich@gmail.com>

-vlad
