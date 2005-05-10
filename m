From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] TCP congestion infrastructure
Date: Tue, 10 May 2005 09:11:23 -0700
Message-ID: <20050510091123.18db2f0d@dxpl.pdx.osdl.net>
References: <20050506173729.20140.93205.37072@galon.ev-en.org>
	<20050509162214.0a8c9ceb@dxpl.pdx.osdl.net>
	<4280C5A4.4050708@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Douglas Leith <doug.leith@nuim.ie>,
        "David S.Miller"
 <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <4280C5A4.4050708@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 10 May 2005 15:31:00 +0100
Baruch Even <baruch@ev-en.org> wrote:

> Stephen Hemminger wrote:
> > I rebased the H-TCP patches on my current work and 2.6.12-rc4 and put them in
> > 	http://developer.osdl.org/shemminger/patches/2.6.12-rc4-tcp/
> > 
> > Includes infrastructure and all the current variants: BIC, Westwood, Vegas
> >     plus  H-TCP, Hybla
> > 
> 
> In the tcpdiag struct you have TCPDIAG_VEGASINFO which is also used by
> WestWood. Maybe a change of name is in order?

I would but, that name is by now committed in the netlink API. Changing it would
break source compatibility.
