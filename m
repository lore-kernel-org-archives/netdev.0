From: Paul P Komkoff Jr <i@stingr.net>
Subject: Re: Was change to ip_push_pending_frames intended to break udp	(more specifically, WCCP?)
Date: Tue, 23 May 2006 00:21:13 +0400
Message-ID: <20060522202113.GA8196@stingr.net>
References: <20060520191153.GV3776@stingr.net> <20060520140434.2139c31b.akpm@osdl.org> <1148322152.15322.299.camel@galen.zko.hp.com> <4472078D.8010706@hp.com> <1148324083.15323.325.camel@galen.zko.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Rick Jones <rick.jones2@hp.com>, Paul P Komkoff Jr <i@stingr.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stingr.net ([212.193.32.15]:18621 "EHLO stingr.net")
	by vger.kernel.org with ESMTP id S1751164AbWEVUVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 May 2006 16:21:16 -0400
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Content-Disposition: inline
In-Reply-To: <1148324083.15323.325.camel@galen.zko.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replying to Vlad Yasevich:
>     /* This is only to work around buggy Windows95/2000
>      * VJ compression implementations.  If the ID field
>      * does not change, they drop every other packet in
>      * a TCP stream using header compression.
>      */

Unfortunately, cisco IOS also complains that packets are "duplicate".
And, regarding to your previous message on how to fix this - IIRC, if
I do connect() on this socket, it will refuse to receive datagrams
from hosts other than specified in connect(), and I will be unable to
bind another socket to the same port on my side.

That said, the only solution which is close to what been before, will
be to keep one socket for receive, and create socket for each router I
am communicating with, right?

-- 
Paul P 'Stingray' Komkoff Jr // http://stingr.net/key <- my pgp key
 This message represents the official view of the voices in my head
