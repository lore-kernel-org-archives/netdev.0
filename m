From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next 0/6] neigh cleanups and fixes
Date: Mon, 18 May 2015 11:30:24 +0800
Message-ID: <55595CD0.9060403@windriver.com>
References: <1431672946-300-1-git-send-email-ying.xue@windriver.com> <1431692082.27831.92.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <alexei@purestorage.com>,
	<joern@purestorage.com>, <ja@ssi.bg>, <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:37705 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbbERDak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 23:30:40 -0400
In-Reply-To: <1431692082.27831.92.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2015 08:14 PM, Eric Dumazet wrote:
> atomic_read() by definition are unsafe.

Can you please recommend which atomic interface can be safely used to check
whether neigh refcnt is zero in the first patch?

Thanks,
Ying
