From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: tunneling in linux (was: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling)
Date: Sun, 16 Jan 2005 22:44:01 +0100
Message-ID: <20050116214401.GG22165@xi.wantstofly.org>
References: <20050112222437.GC14280@xi.wantstofly.org> <200501162237.33743.hasso@estpak.ee> <20050116212124.GF22165@xi.wantstofly.org> <200501162332.38798.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com,
        Pekka Savola <pekkas@netcore.fi>, shemminger@osdl.org,
        shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
Content-Disposition: inline
In-Reply-To: <200501162332.38798.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jan 16, 2005 at 11:32:38PM +0200, Hasso Tepper wrote:

> > > > > BTW, have you looked at any of the L2VPN stuff? browse the ietf web
> > > > > page. Some interesting stuff there.
> > > >
> > > > The L2TP RFC (RFC 2661, is that the same thing?) is 170kB, which
> > > > scared me off somewhat.
> > >
> > > If L2TP, then v3 probably - RFC3931.
> >
> > That RFC appears not to exist.
> 
> Hmmm. Yes, seems that there was decision for yet another draft before 3931 
> was made official. Some sites contain info about it though. So official one 
> at the moment:
> 
> http://www.ietf.org/internet-drafts/draft-ietf-l2tpext-l2tp-base-15.txt

Things like this make me shiver:

<quote>
Appendix A: Control Slow Start and Congestion Avoidance

   Although each side has indicated the maximum size of its receive
   window, it is recommended that a slow start and congestion avoidance
   method be used to transmit control packets.  The methods described
   here are based upon the TCP congestion avoidance algorithm as
   described in Section 21.6 of TCP/IP Illustrated, Volume I, by W.
   Richard Stevens [STEVENS] (this algorithm is also described in
   [RFC2581]).

   [snip]
</quote>

For some reason, people really really like reinventing TCP.

I'm definitely not going to implement this, all I wanted from the very
beginning is a _simple_ way of tunneling ethernet packets.  :-)


--L
