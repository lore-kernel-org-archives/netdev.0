From: Lennert Buytenhek <buytenh@gnu.org>
Subject: Re: [PATCH,RFC] explicit connection confirmation
Date: Thu, 7 Nov 2002 10:27:58 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021107152758.GB23858@gnu.org>
References: <20021107120956.GA10832@gnu.org> <Pine.GSO.4.30.0211070834130.11358-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>, Marc Boucher <marc@mbsi.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0211070834130.11358-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

netfilter, yeah, sure, 'could have', but please.

'Make it a netfilter module' is generally what people say when
they are confronted with a feature they don't like.

There was a thread about this in private mail round April this year,
in which some good points were raised.

- From the kernel point of view, doing it in netfilter would require
  more state tracking and access to the socket hashes and would be
  uglier.

- From the application writer's point of view, doing it via a socket
  option is much more intuitive, since this flag is really a socket
  property, than doing it via some extra API which would make it way
  too difficult/complex to use in existing apps.

It's worth noting that selective TCP connection acceptance was
also intended to be implemented as a socket option by the original
BSD developers.  See http://www.kohala.com/start/vanj.94jun27.txt
(link thanks to Marc Boucher).

>From the accept(2) man page on Red Hat Linux (again thanks to Marc
Boucher):

       For  certain  protocols which require an explicit confirmation, such as
       DECNet, accept can be thought of as merely dequeuing the  next  connec-
       tion  request  and  not  implying  confirmation.   Confirmation  can be
       implied by a normal read or write  on  the  new  file  descriptor,  and
       rejection can be implied by closing the new socket. Currently only DEC-
       Net has these semantics on Linux.


cheers,
Lennert



On Thu, Nov 07, 2002 at 08:36:28AM -0500, jamal wrote:

> Could you not have used netfilter for this? You have the app
> sending controls to add netfilter policies and delete them when not
> needed.
> 
> cheers,
> jamal
> 
> 
> 
