From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: Was change to ip_push_pending_frames intended to break
	udp	(more specifically, WCCP?)
Date: Mon, 22 May 2006 17:10:15 -0400
Message-ID: <1148332215.15323.368.camel@galen.zko.hp.com>
References: <20060520191153.GV3776@stingr.net>
	 <20060520140434.2139c31b.akpm@osdl.org>
	 <1148322152.15322.299.camel@galen.zko.hp.com> <4472078D.8010706@hp.com>
	 <1148324083.15323.325.camel@galen.zko.hp.com>
	 <20060522202113.GA8196@stingr.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:61639 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1750868AbWEVVKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 May 2006 17:10:19 -0400
To: Paul P Komkoff Jr <i@stingr.net>
In-Reply-To: <20060522202113.GA8196@stingr.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-05-23 at 00:21 +0400, Paul P Komkoff Jr wrote:
> Replying to Vlad Yasevich:
> >     /* This is only to work around buggy Windows95/2000
> >      * VJ compression implementations.  If the ID field
> >      * does not change, they drop every other packet in
> >      * a TCP stream using header compression.
> >      */
> 
> Unfortunately, cisco IOS also complains that packets are "duplicate".
> And, regarding to your previous message on how to fix this - IIRC, if
> I do connect() on this socket, it will refuse to receive datagrams
> from hosts other than specified in connect(), and I will be unable to
> bind another socket to the same port on my side.
> 
> That said, the only solution which is close to what been before, will
> be to keep one socket for receive, and create socket for each router I
> am communicating with, right?

Yewwww...  I see you problem.

To me this sounds like a bug in IOS.  I hope someone else would comment.

I did previously search a bunch of RFC and nowhere did a find a
requirement that IDs should be non-zero when DF bit is set.  The only
time IP IDs are mentioned is in the fragmentation and reassembly
description. 

-vlad

