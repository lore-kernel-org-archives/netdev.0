From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] fq_codel: fix return value of fq_codel_drop()
Date: Wed, 15 Jul 2015 08:27:35 +0200
Message-ID: <1436941655.1026.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1436898118-30804-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1436898118-30804-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:36360 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbbGOG1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 02:27:39 -0400
Received: by wgxm20 with SMTP id m20so24796967wgx.3
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 23:27:38 -0700 (PDT)
In-Reply-To: <1436898118-30804-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-07-14 at 11:21 -0700, Cong Wang wrote:
> The ->drop() is supposed to return the number of bytes it dropped,
> however fq_codel_drop() returns the index of the flow where it drops
> a packet from.
> 
> Fix this by introducing a helper to wrap fq_codel_drop().
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> ---

SGTM, thanks Cong.

Acked-by: Eric Dumazet <edumazet@google.com>
