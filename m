From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 2/2] netpoll: Don't poll for received packets
Date: Tue, 11 Mar 2014 05:44:23 -0700
Message-ID: <1394541863.21721.25.camel@edumazet-glaptop2.roam.corp.google.com>
References: <871ty9qvaf.fsf_-_@xmission.com>
	 <87vbvlpgnk.fsf_-_@xmission.com>
	 <1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140311.004217.1616529960369263682.davem@davemloft.net>
	 <1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a9cxf7mp.fsf_-_@xmission.com> <87wqg1dsyw.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:49758 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377AbaCKMo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 08:44:26 -0400
Received: by mail-pb0-f44.google.com with SMTP id rp16so8758276pbb.31
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 05:44:25 -0700 (PDT)
In-Reply-To: <87wqg1dsyw.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-11 at 01:45 -0700, Eric W. Biederman wrote:
> When calling drivers napi poll function pass it a budget of 0, to
> request that no rx packets be processed, and warn if any rx packets
> are actually processed.
> 
> Additionally remove the drop_mon tracepoint as nothing interesting
> should be happening in netpoll, and running an arbitrary tracepoint
> in irq context is probably a bad idea.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  net/core/netpoll.c |   28 +++++++++-------------------
>  1 files changed, 9 insertions(+), 19 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
