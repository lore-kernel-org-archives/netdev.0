From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [IPX]: Fix checksum computation.
Date: Fri, 31 Oct 2003 20:46:04 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031031224603.GT3705@conectiva.com.br>
References: <200310312006.h9VK62Hh005910@hera.kernel.org> <1067635446.11564.92.camel@localhost.localdomain> <20031031132331.35a9aaca.davem@redhat.com> <1067637004.11564.98.camel@localhost.localdomain> <20031031135328.2a997f6a.davem@redhat.com> <20031031142131.07176dd7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Joe Perches <joe@perches.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031031142131.07176dd7.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Fri, Oct 31, 2003 at 02:21:31PM -0800, Stephen Hemminger escreveu:
> On Fri, 31 Oct 2003 13:53:28 -0800
> "David S. Miller" <davem@redhat.com> wrote:
> 
> > On Fri, 31 Oct 2003 13:50:04 -0800
> > Joe Perches <joe@perches.com> wrote:
> > 
> > > Was an old NG Sniffer being used to verify this?
> > > Sniffer had a long term problem with IPX checksums.
> > 
> > No, Arnaldo would verify the checksum by running the
> > old code and the new code, they produced different
> > checksums on every sendmsg() call.
> > 
> > He then tested it further by making sure he could use
> > netatalk successfully between a 2.4.x Linux appletalk
> > box and a 2.6.x system with the checksum patch applied.
> > Without the patch the 2.4.x system would reject all packets
> > sent by the 2.6.x box.
> >
> 
> Actually, the before the "optimization" went in I did testing between
> old 2.4.x and 2.6.x as well as standalone comparisons.  The problem is
> a compiler screwup, that probably isn't worth investigating further.

But if someone wants to I'd be glad to receive test reports with and without
the patch.

Hey, that way we can get more testers for Appletalk in 2.6 8)

- Arnaldo
