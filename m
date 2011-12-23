From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH v2] rps: fix insufficient bounds checking in store_rps_dev_flow_table_cnt()
Date: Fri, 23 Dec 2011 00:56:50 -0500
Message-ID: <4DA4756B-0654-49F4-B135-9A9F89BC7D21@gmail.com>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com> <4EF3BEBA.4040402@gmail.com> <1324613414.2674.2.camel@edumazet-laptop> <C0DC969A-A32B-4CC8-B565-FF741E9D75DA@gmail.com> <1324616007.2674.8.camel@edumazet-laptop> <ACB00AE8-CFEF-4535-9242-1B5C44F05C13@gmail.com> <1324617390.2674.13.camel@edumazet-laptop> <1324618555.10854.4.camel@edumazet-laptop>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34068 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718Ab1LWF4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 00:56:54 -0500
Received: by iaeh11 with SMTP id h11so14585146iae.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 21:56:54 -0800 (PST)
In-Reply-To: <1324618555.10854.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 23, 2011, at 12:35 AM, Eric Dumazet wrote:
> By the way, the theorical limit on number of flows on 64bit platform is
> 2^32  (rxhash being an u32)
> 
> Not sure spending 32GB per table would be wise for typical machines :)

True, a large rps_flow_cnt is not that useful. ;-)

Anyway, my point is that if the patch looks confusing to you, then
it is probably not good.  I am happy to see a more elegant fix.

- xi
