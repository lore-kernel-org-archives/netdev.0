From: James Morris <jmorris@namei.org>
Subject: Re: netlink recvmsg() and MSG_TRUNC
Date: Tue, 6 Mar 2007 18:40:57 -0500 (EST)
Message-ID: <Line.LNX.4.64.0703061839450.25840@d.namei>
References: <20070306.151953.112290310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:43205 "EHLO
	mail8.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030721AbXCFXk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 18:40:59 -0500
In-Reply-To: <20070306.151953.112290310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Mar 2007, David Miller wrote:

> I guess one thing the user could do when it sees MSG_TRUNC
> is keep calling recvmsg() until the receive queue is emptied
> of packets, in order to get that pesky nlk->cb cleared to
> NULL, then resubmit.
> 
> But that's rediculous and complicated.
> 
> Any ideas?

Only slightly less complicated: user calls recvmsg() once with a new flag 
MSG_FLUSH, which causes the queue to be flushed, then resubmits ?


- James
-- 
James Morris
<jmorris@namei.org>
