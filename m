From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sunvnet: set queue mapping when doing packet copies
Date: Thu, 29 Jan 2015 10:19:51 -0800
Message-ID: <1422555591.21689.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54C90AED.7040404@oracle.com> <54CA63E6.3020603@oracle.com>
	 <1422555146.21689.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:52571 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbbA2STw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 13:19:52 -0500
Received: by mail-ie0-f176.google.com with SMTP id rd18so36825965iec.7
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 10:19:52 -0800 (PST)
In-Reply-To: <1422555146.21689.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-29 at 10:12 -0800, Eric Dumazet wrote:

> swap(nskb->sk, skb->sk);
> swap(nskb->truesize, skb->truesize);

and swap(nskb->destructor, skb->destructor);

(check skb_segment() for a similar path)
