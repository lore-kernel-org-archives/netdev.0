From: Pekka Savola <pekkas@netcore.fi>
Subject: host vs interface address ownership [Re: [2.4 PATCH] bugfix: ARP
 respond on all devices]
Date: Wed, 20 Aug 2003 08:18:09 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308200809280.32417-100000@netcore.fi>
References: <20030819095611.0fb8f9a3.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Richard Underwood <richard@aspectgroup.co.uk>, <skraw@ithnet.com>,
   <willy@w.ods.org>, <alan@lxorguk.ukuu.org.uk>, <carlosev@newipnet.com>,
   <lamont@scriptkiddie.org>, <davidsen@tmr.com>, <bloemsaa@xs4all.nl>,
   <marcelo@conectiva.com.br>, <netdev@oss.sgi.com>,
   <linux-net@vger.kernel.org>, <layes@loran.com>, <torvalds@osdl.org>,
   <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030819095611.0fb8f9a3.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003, David S. Miller wrote:

> On Tue, 19 Aug 2003 13:02:20 +0100
> Richard Underwood <richard@aspectgroup.co.uk> wrote:
> 
> > David S. Miller wrote:
> > > Under Linux, by default, IP addresses are owned by the system
> > > not by interfaces.  This increases the likelyhood of successful
> > > communication on a subnet.
> > > 
> > 	This is crap.
> 
> Nope, the RFCs allow this.
> 
> So this is where we must agree to disagree.  Because host ownership of
> IP addresses is the basis for all of the arguments and it completely
> justifies Linux's ARP behavior on both sides.

Maybe I'm missing something -- I'm not sure what exactly you're including
in the models -- but wouldn't it be possible to implement the "host 
ownership" model so that it would STILL honor any RFC out there (and 
similarly for "interface ownership")?

For example, many IETF documents may state things like:

                                                                     The
   Home Agents List MAY be implemented in any manner consistent with the
   external behavior described in this document.

.. which *seems* (without knowing which RFCs and sections of them you 
refer to for justifying host/interface ownership) to be a probable intent 
of allowing either model.  Just as long as the external behaviour is 
consistent, you can implement it with any internal structure you wish.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
