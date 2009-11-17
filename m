From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next-2.6 PATCH v6 4/7 RFC] TCPCT part 1d: define TCP cookie
 option, extend existing struct's
Date: Tue, 17 Nov 2009 14:38:42 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911171432420.7024@wel-95.cs.helsinki.fi>
References: <4B01D17C.4010407@gmail.com> <20091116.191522.178198674.davem@davemloft.net> <alpine.DEB.2.00.0911171412380.7024@wel-95.cs.helsinki.fi> <20091117.042250.28821014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1666960572-1258461522=:7024"
Cc: eric.dumazet@gmail.com, william.allen.simpson@gmail.com,
	Netdev <netdev@vger.kernel.org>, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58804 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356AbZKQMig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 07:38:36 -0500
In-Reply-To: <20091117.042250.28821014.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1666960572-1258461522=:7024
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: 8BIT

On Tue, 17 Nov 2009, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Tue, 17 Nov 2009 14:18:57 +0200 (EET)
> 
> > On Mon, 16 Nov 2009, David Miller wrote:
> > 
> >> From: Eric Dumazet <eric.dumazet@gmail.com>
> >> Date: Mon, 16 Nov 2009 23:26:04 +0100
> >> 
> >> > So adding DATA to SYN packets might be problematic for part of our tcp 
> >> > stack. 
> >> 
> >> I can almost guarentee it won't work.  For one thing getting a SACK
> >> response to a SYN+DATA packet will explode quite nicely for one thing.
> > 
> > Now I'm really lost??? How can you get SACKs for that in the first 
> > place since they are either lost or delivered in unison???
> 
> Ideally, you're probably right.
> 
> However, it seems to me that the receiver can do whatever it likes
> with it's receive queue when it's under memory pressure.
> 
> It can chop packets up, partially free bits, and then send a SACK
> block back to you for the parts it tried to free.
> 
> If you'll recall, I wanted to put some tough restrictions into what is
> allowed with SACK so that we could optimize things on the sender side.
> But there was resistence and therefore we have to keep allowing all
> kinds of silly situations, the one we're talking about here merely
> being one of them :-)

Right, but we could be just as crazy and just drop such things and keep 
resending SYN+DATA without any harm?

-- 
 i.
--8323329-1666960572-1258461522=:7024--
