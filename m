From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next-2.6 PATCH v6 4/7 RFC] TCPCT part 1d: define TCP cookie
 option, extend existing struct's
Date: Tue, 17 Nov 2009 14:07:08 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911171402260.7024@wel-95.cs.helsinki.fi>
References: <4AFCDA9E.8050003@gmail.com> <4AFCE65C.2010104@gmail.com> <4AFCFD86.6020504@gmail.com> <4AFD8421.6090003@gmail.com> <4B01BB33.7080702@gmail.com> <4B01BF65.1010203@gmail.com> <4B01CD8D.1000305@gmail.com> <4B01D17C.4010407@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-178840925-1258459523=:7024"
Cc: William Allen Simpson <william.allen.simpson@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47239 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116AbZKQMHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 07:07:04 -0500
In-Reply-To: <4B01D17C.4010407@gmail.com>
Content-ID: <alpine.DEB.2.00.0911171405310.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-178840925-1258459523=:7024
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0911171405311.7024@wel-95.cs.helsinki.fi>

On Mon, 16 Nov 2009, Eric Dumazet wrote:

> William Allen Simpson a écrit :
> > Eric Dumazet wrote:
> > 
> >> I remember a previous remark from David that our skb queues would not
> >> contain
> >> DATA on SYN packets...
> >>
> > I haven't seen anything by David, but there's an existing comment in
> > tcp_input.c at the place where SYN data will be added later:
> > 
> 
> Yep, David comment was about another netdev thread, while tracking an 
> obscure bug 
> 
> http://www.spinics.net/lists/netdev/msg110759.html
> 
> http://www.spinics.net/lists/netdev/msg110764.html
> 
> 
> So adding DATA to SYN packets might be problematic for part of our tcp 
> stack. 

You both are right (and that's what is causing confusion)... What DaveM 
said is this:

"And we're only dealing with data packets once we enter established
state, and when we enter established by definition we have unlinked
and freed up any SYN and SYN+ACK SKBs in the write queue."

We certainly can have SYN/SYNACKs in write queue but not in certain 
states, and consequently, not in certain functions.


-- 
 i.
--8323329-178840925-1258459523=:7024--
