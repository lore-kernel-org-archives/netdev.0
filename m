From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: udp weirdness
Date: Fri, 27 Sep 2002 18:04:12 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020927150412.GI30392@mea-ext.zmailer.org>
References: <20020927120223.GH343@hookipa> <Pine.GSO.4.30.0209271048160.4401-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0209271048160.4401-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 27, 2002 at 10:53:00AM -0400, jamal wrote:
> On Fri, 27 Sep 2002, Eric Lemoine wrote:
>=20
> > I figured out that packets can be dropped in pfifo_fast_enqueue()
> > [the default qdisc's enqueue func], even though the driver/kernel
> > flow control has triggered.
=2E..
> What trigger do you suggest to wake up the process again?
> A better idea maybe to return something to the socket so it can
> manage things instead -- not sure what to return though that wouldnt
> break some standard;


"man sendto" error return codes:

       ENOBUFS
              The  output queue for a network interface was full.
              This generally indicates  that  the  interface  has
              stopped  sending,  but  may  be caused by transient
              congestion.  (This cannot occur in  Linux,  packets
              are just silently dropped when a device queue over=AD
              flows.)

> cheers,
> jamal

/Matti Aarnio
