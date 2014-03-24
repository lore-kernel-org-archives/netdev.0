From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: delete unused parameter in tcp_nagle_check()
Date: Mon, 24 Mar 2014 06:08:47 -0700
Message-ID: <1395666527.12610.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <4609be8bb5dacb54d14e1b1f5dc8264b85c7c8d3.1395630957.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:58069 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbaCXNIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 09:08:49 -0400
Received: by mail-pd0-f181.google.com with SMTP id p10so5300571pdj.40
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 06:08:49 -0700 (PDT)
In-Reply-To: <4609be8bb5dacb54d14e1b1f5dc8264b85c7c8d3.1395630957.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 14:49 +0800, Weiping Pan wrote:
> After commit d4589926d7a9 (tcp: refine TSO splits), tcp_nagle_check() does
> not use parameter mss_now anymore.
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>
> ---

Its not a fix and should target net-next, otherwise it looks good to me.

Thanks
