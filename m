From: "John Que" <qwejohn@gmail.com>
Subject: Re: determine outgoing interface (eth0,eth1) for a packet according to the dest IP
Date: Wed, 26 Apr 2006 13:24:45 +0300
Message-ID: <ada605fb0604260324n4dc99556j300bfd433a9027d9@mail.gmail.com>
References: <ada605fb0604250031r2e4a74e7id0b5079fabde9517@mail.gmail.com>
	 <200604250943.49422.ak@suse.de>
	 <ada605fb0604250744w73c7766as1d3ceb0d62511764@mail.gmail.com>
	 <200604251648.10113.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from uproxy.gmail.com ([66.249.92.175]:61380 "EHLO uproxy.gmail.com")
	by vger.kernel.org with ESMTP id S932312AbWDZKYq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 06:24:46 -0400
Received: by uproxy.gmail.com with SMTP id c2so1214079ugf
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 03:24:45 -0700 (PDT)
To: "Andi Kleen" <ak@suse.de>
In-Reply-To: <200604251648.10113.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Does anybody knows where suh a code example
which gets routing info according to the destination IP using
GETROUTE netlink sockets
can be found ?

I had spent time trying to write something which
uses RTA_SRC and RTA_DST and got some problems.
(I probably made something stupid.)
I googled for such examples and did not get much.
I saw that the zebra project and iproute uses
netlinks but it is complex.,

TIA
John

On 4/25/06, Andi Kleen <ak@suse.de> wrote:
> On Tuesday 25 April 2006 16:44, John Que wrote:
> > Thanks a lot !
> >
> >   I had tried the sending RTM_GETROUTE message using a NETLINK_ROUTE
> >       socket in a User Space program and it went OK.
> >
> >       It gaves correct routing struct which I could parse.
> >       In fact it gave the rotuing table.
> >       But in sending that message I did not specify a certain
> >       dest IP.
> >       Consider the follwing simple scenario: I have 2 gateways
> >       (one on eth0,one on eth1), and I am sending
> >       a packet to some dest IP ; I want to know according to
> >       that ip on which interface (or gw) it will be out
> >
> >       But where do I specify that certain dest IP ?
>
> You add RTA_SRC and RTA_DST attributes to the query.
>
> -Andi
>
