From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 19:24:35 +0100
Message-ID: <20160324182435.GA7682@1wt.eu>
References: <1458828813.10868.65.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160324142222.GB7237@1wt.eu>
 <1458830744.10868.72.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160324153053.GA7569@1wt.eu>
 <1458837191.12033.4.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160324165047.GA7585@1wt.eu>
 <1458838897.12033.10.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S36Ej1es8qFi2Q3=199f+rmG=Za02N5ZBWT5DCRqrBEWvQ@mail.gmail.com>
 <56F42A00.7050002@iogearbox.net>
 <CALmu+SxF5dDEBwpk-R=V5DGZBed1rvjYGEJ+cU8ZhyAdLWshug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Craig Gallek <cgallek@google.com>,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tolga Ceylan <tolga.ceylan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:32149 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154AbcCXSYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2016 14:24:53 -0400
Content-Disposition: inline
In-Reply-To: <CALmu+SxF5dDEBwpk-R=V5DGZBed1rvjYGEJ+cU8ZhyAdLWshug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 11:20:49AM -0700, Tolga Ceylan wrote:
> I would appreciate a conceptual description on how this would work
> especially for a common scenario
> as described by Willy. My initial impression was that a coordinator
> (master) process takes this
> responsibility to adjust BPF filters as children come and go.

Indeed that would help, I don't know where to start from for now.

> Two popular software has similar use cases: nginx and haproxy. Another
> concern is with the
> introduction of BPF itself, should we expect a performance drop in
> these applications?

Knowing how picky Eric is about performance in such areas, I'm not
worried a single second about adopting something he recommends :-)
I just need to ensure it covers our users' needs. And maybe the
solution I mentionned in the other e-mail could work.

Willy
