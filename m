From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv6: replace write lock with read lock when get
 route info
Date: Wed, 12 Sep 2012 10:12:59 +0200
Message-ID: <1347437580.13103.698.camel@edumazet-glaptop>
References: <1347436741-344-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:43000 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416Ab2ILINE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 04:13:04 -0400
Received: by eaac11 with SMTP id c11so676771eaa.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 01:13:03 -0700 (PDT)
In-Reply-To: <1347436741-344-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-12 at 15:59 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> geting route info does not write rt->rt6i_table, so replace
> write lock with read lock
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/ipv6/addrconf.c |    4 ++--
>  net/ipv6/route.c    |    8 ++++----
>  2 files changed, 6 insertions(+), 6 deletions(-)

I guess you missed the net-next tag in your [PATCH ...] ?
 
Signed-off-by: Eric Dumazet <edumazet@google.com>
