From: "Maciej W. Rozycki" <macro@ds2.pg.gda.pl>
Subject: Re: RFC:  Enabling ethernet drivers to return FCS in the skb?
Date: Wed, 19 Nov 2003 14:20:24 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.55.0311191400010.19479@jurand.ds.pg.gda.pl>
References: <3FB94311.10004@candelatech.com> <20031119123556.A7622@sygehus.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031119123556.A7622@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 19 Nov 2003, Rask Ingemann Lambertsen wrote:

> > Is there any interest in adding an Ethtool command to tell the driver to
> > push the extra 4 bytes of CSUM into the skb?
> > 
> > When enabling this feature, I'd also like to allow drivers to receive
> > frames with bad FCS as well.
> [cut]
> > At least some hardware appears
> > to support receiving bad FCS frames (e1000, evidently), but I am not sure
> > how wide-spread this feature is...
> 
> The Intel i82586 and i82596 and can be told to receive frames with a bad FCS.
> They can also be told to send a precomputed FCS rather than computing it on
> the fly. The i82596 and tulip can also transfer the FCS to memory when
> receiving frames. I guess all of this is also supported on the i82557/8/9.

 FYI, all DEC FDDI controllers we currently support (or support is being
worked on) do support receiving bad frames -- all frames are always passed
to the rx path and it's up to a driver to decide if a bad frame should be
completely discarded or other actions should be taken.  By specification
the boards also support sending frames with a manually calculated
checksum, which may possibly be intentionally wrong, but I haven't
actually tested it.

 If such functionality is added for Ethernet boards, I'm willing to 
support it for these DEC FDDI boards as well.

-- 
+  Maciej W. Rozycki, Technical University of Gdansk, Poland   +
+--------------------------------------------------------------+
+        e-mail: macro@ds2.pg.gda.pl, PGP key available        +
