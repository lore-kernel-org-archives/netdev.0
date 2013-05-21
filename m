From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GRE+XFRM+GSO crashes
Date: Tue, 21 May 2013 15:46:15 -0700
Message-ID: <1369176375.3301.259.camel@edumazet-glaptop>
References: <20130520094127.546a2f3e@vostro>
	 <CALnjE+qgOQUDm_gAuygpDE5VH23YS0i3QyQuCVPhgu15=jwXWw@mail.gmail.com>
	 <20130521110132.37dc2665@vostro>
	 <CALnjE+qOf2pxzP0-7s4AsSNDbG5M5s8bXFDqYoD-5NgmtKYixA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:50528 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab3EUWqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 18:46:17 -0400
Received: by mail-oa0-f43.google.com with SMTP id o6so1618420oag.2
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 15:46:17 -0700 (PDT)
In-Reply-To: <CALnjE+qOf2pxzP0-7s4AsSNDbG5M5s8bXFDqYoD-5NgmtKYixA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-21 at 15:32 -0700, Pravin Shelar wrote:

> OK. I am still not able to reproduce it, Can you try attached patch?
> if that works, I will send out proper patch.

strange, dev_gso_segment() doesnt change skb->cb[]
only dev_gso_segment() does.
