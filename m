From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next] fou: avoid missing unlock in failure path
Date: Tue, 14 Apr 2015 11:25:35 -0700
Message-ID: <CAHA+R7NH_xUS99L62K68ZF+_=7MWNJ3aC_MS_mfQmEQuRWKvRA@mail.gmail.com>
References: <1429029150-31710-1-git-send-email-xiyou.wangcong@gmail.com>
	<1429030869.7346.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34667 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753356AbbDNSZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 14:25:37 -0400
Received: by widjs5 with SMTP id js5so94683186wid.1
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 11:25:35 -0700 (PDT)
In-Reply-To: <1429030869.7346.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2015 at 10:01 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> When was this bug added ?

Fixes: 7a6c8c34e5b7 ("fou: implement FOU_CMD_GET")
