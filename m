From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next-2.6 PATCH v6 4/7 RFC] TCPCT part 1d: define TCP cookie
 option, extend existing struct's
Date: Tue, 17 Nov 2009 14:18:57 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911171412380.7024@wel-95.cs.helsinki.fi>
References: <4B01BF65.1010203@gmail.com> <4B01CD8D.1000305@gmail.com> <4B01D17C.4010407@gmail.com> <20091116.191522.178198674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, william.allen.simpson@gmail.com,
	Netdev <netdev@vger.kernel.org>, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57335 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755860AbZKQMSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 07:18:51 -0500
In-Reply-To: <20091116.191522.178198674.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Nov 2009, David Miller wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 16 Nov 2009 23:26:04 +0100
> 
> > So adding DATA to SYN packets might be problematic for part of our tcp 
> > stack. 
> 
> I can almost guarentee it won't work.  For one thing getting a SACK
> response to a SYN+DATA packet will explode quite nicely for one thing.

Now I'm really lost??? How can you get SACKs for that in the first 
place since they are either lost or delivered in unison???

> A lot of the other retransmit queue handling would need to be audited
> as well.  So much code assumes that if we see sent data in the
> retransmit queue, there won't be SYN or SYN+ACK things in there to
> contend with.

...Valid ACKs will either remove that SYN+DATA segment completely, other 
ACK could (or should) just be dropped. I kind of fail to see what is the 
problem here.

-- 
 i.
