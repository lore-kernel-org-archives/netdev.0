From: Jon Paul Maloy <jon.maloy@donjonn.com>
Subject: SV: Re: [tipc-discussion] [RFC: 2.6 patch] net/tipc/: possible cleanups
Date: Sun, 25 Feb 2007 19:56:26 +0100 (CET)
Message-ID: <812945.13617.qm@web710.biz.mail.mud.yahoo.com>
References: <20070225161411.GX12392@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web710.biz.mail.mud.yahoo.com ([209.191.119.235]:43259 "HELO
	web710.biz.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965095AbXBYS41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Feb 2007 13:56:27 -0500
In-Reply-To: <20070225161411.GX12392@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Adrian Bunk <bunk@stusta.de> skrev:

> It can be re-added at any time when an in-kernel
> user comes.
> 
> But the most interesting question is:
> Why is noone interested in getting his TIPC using
> drivers merged?
> 
I don't think lack of interest is the issue here. The
users I know anything about, would be both happy and
proud to contribute code to the main tree. One I know
about,who has developed a very interesting "reliable
bond interface" based on this API, doesn't regard his
code to be up to the kernel coding standards yet,
although I am trying to encourage him. Another one
thinks his function is just too specialized to be of
any common interest.
In the future, I would be also be very interested in
seeing a cross-node netlink implementation, carried
over TIPC, using this API. (Unfortunately, I don't
dare to commit to this myself right now, there is too
much left to be done in TIPC.)
So, as you see, keeping the exported symbols would be
a definite advantage, as current and future developers
would not have to patch the kernel to do their work.

Regards
///jon 
