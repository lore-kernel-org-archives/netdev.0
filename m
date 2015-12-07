From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPsec workshop/BoF at netdev1.1?
Date: Mon, 07 Dec 2015 08:20:01 -0800
Message-ID: <1449505201.25029.61.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151207120054.GI14008@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35542 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756031AbbLGQUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 11:20:04 -0500
Received: by pacej9 with SMTP id ej9so127319223pac.2
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 08:20:04 -0800 (PST)
In-Reply-To: <20151207120054.GI14008@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-12-07 at 13:00 +0100, Steffen Klassert wrote:
> Is there any interest in doing an IPsec workshop/BoF at netdev1.1?
> 
> This mail is to probe if we can gather enough discussion topics to run
> such a workshop/BoF. So if someone is interested to attend and/or has a
> related discussion topic, please let me know.
> 
> My current topics:
> 
> - Adding a software GRO/GSO codepath for IPsec. I have working example code,
>   a RFC version could be ready before the netdev conference.


- Remove rwlock usage (xfrm_policy_lock) from fast path and szitch to
RCU ?




>  Can we support IPsec offloading to NICs? There are NICs that can handle
>   IPsec, so what are the requirements to support this?
> 
