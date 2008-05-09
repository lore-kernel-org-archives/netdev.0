From: "Paul Marks" <paul@pmarks.net>
Subject: Re: When should kfree_skb be used?
Date: Thu, 8 May 2008 23:34:59 -0700
Message-ID: <8e5b27790805082334g6c5a1752pd42ab291ac6b33af@mail.gmail.com>
References: <8e5b27790805082149y6d9f604ds7feefe2804f3823c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:59452 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbYEIGfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 02:35:02 -0400
Received: by yw-out-2324.google.com with SMTP id 9so641721ywe.1
        for <netdev@vger.kernel.org>; Thu, 08 May 2008 23:34:59 -0700 (PDT)
In-Reply-To: <8e5b27790805082149y6d9f604ds7feefe2804f3823c@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 8, 2008 at 9:49 PM, Paul Marks <paul@pmarks.net> wrote:
> Hi, I'm trying to make sense of the ipip6_rcv function here:
>
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=net/ipv6/sit.c;hb=HEAD#l564
>

I've been looking at more uses of pskb_may_pull(), and almost all of
them seem to kfree_skb() after a failure.  Could this occurence in
sit.c be a bug?  It looks like this line was added by davem for linux
2.4.4 in 2001, and hasn't changed since.
