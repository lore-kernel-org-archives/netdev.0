From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] skbuff: Add skb_list_linearize()
Date: Tue, 20 Jan 2015 15:51:20 -0800
Message-ID: <1421797880.4832.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421785543-19823-1-git-send-email-pshelar@nicira.com>
	 <1421790195.4832.12.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALnjE+pDdvcSdQV83J_DLJwmcM8OsC94xDnH2mSSsxDCNnsztg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:56211 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbbATXvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 18:51:23 -0500
Received: by mail-ig0-f181.google.com with SMTP id hn18so5921555igb.2
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 15:51:22 -0800 (PST)
In-Reply-To: <CALnjE+pDdvcSdQV83J_DLJwmcM8OsC94xDnH2mSSsxDCNnsztg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-20 at 14:46 -0800, Pravin Shelar wrote:

> In current use-case it is never called for skb which is tied to
> socket. But I agree it need to be fixed. I can call skb_orphan() to
> fix it.

I would do nothing at all, like skb_linearize()
