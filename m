From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] act_mirred: don't clone skb when skb isn't shared
Date: Sat, 05 Jun 2010 09:59:44 -0400
Message-ID: <1275746384.3490.63.camel@bigi>
References: <1275658990-15838-1-git-send-email-xiaosuo@gmail.com>
	 <1275742435.3490.31.camel@bigi>
	 <AANLkTikHqzIr-SjPZe-iiMPxVG9PRR9-0A9qeMwzfLYp@mail.gmail.com>
	 <1275744299.3490.48.camel@bigi>
	 <AANLkTinh6OylNU8NLXB6ZSb012AmzkFhzFQWPR-iAsrf@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:45004 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933384Ab0FEN7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 09:59:47 -0400
Received: by vws5 with SMTP id 5so1045622vws.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 06:59:47 -0700 (PDT)
In-Reply-To: <AANLkTinh6OylNU8NLXB6ZSb012AmzkFhzFQWPR-iAsrf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-06-05 at 21:33 +0800, Changli Gao wrote:

> 
> If you kill TC_OK2MUNGE, you should kill TC_MUNGED too, as it will
> become useless.

Those two have different semantics and use different verdict bits:
one is saying "this packet has been munged" another is "I give you ok to
munge this packet".
Thanks for the suggestion - I will think about it some more before
deleting anything.

cheers,
jamal

