From: Werner Almesberger <werner@almesberger.net>
Subject: Re: TOE brain dump
Date: Mon, 4 Aug 2003 16:24:33 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030804162433.L5798@almesberger.net>
References: <20030802140444.E5798@almesberger.net> <3F2BF5C7.90400@us.ibm.com> <3F2C0C44.6020002@pobox.com> <20030802184901.G5798@almesberger.net> <m1fzkiwnru.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Nivedita Singhvi <niv@us.ibm.com>,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Content-Disposition: inline
In-Reply-To: <m1fzkiwnru.fsf@frodo.biederman.org>; from ebiederm@xmission.com on Sun, Aug 03, 2003 at 01:21:09PM -0600
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> The optimized for low latency cases seem to have a strong
> market in clusters.

Clusters have captive, no, _desperate_ customers ;-) And it
seems that people are just as happy putting MPI as their
transport on top of all those link-layer technologies.

> There is one place in low latency communications that I can think
> of where TCP/IP is not the proper solution.  For low latency
> communication the checksum is at the wrong end of the packet.

That's one of the few things ATM's AAL5 got right. But in the end,
I think it doesn't really matter. At 1 Gbps, an MTU-sized packet
flies by within 13 us. At 10 Gbps, it's only 1.3 us. At that point,
you may well treat it as an atomic unit.

> On that score it is worth noting that the next generation of
> peripheral busses (Hypertransport, PCI Express, etc) are all switched.

And it's about time for that :-)

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina     werner@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
