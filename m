From: Phil Sutter <phil@nwl.cc>
Subject: Re: Single socket with TX_RING and RX_RING
Date: Thu, 16 May 2013 13:52:07 +0200
Message-ID: <20130516115207.GC18282@orbit.nwl.cc>
References: <loom.20130515T144941-798@post.gmane.org>
 <20130515224452.7CAA6224C4@mail.nwl.cc>
 <loom.20130516T111446-437@post.gmane.org>
 <20130516104541.GB18282@orbit.nwl.cc>
 <loom.20130516T125157-378@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ricardo =?utf-8?B?VHViw61v?= <rtpardavila@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:50967 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753438Ab3EPLwe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 07:52:34 -0400
Content-Disposition: inline
In-Reply-To: <loom.20130516T125157-378@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 16, 2013 at 11:01:17AM +0000, Ricardo Tub=C3=ADo wrote:
> Phil Sutter <phil <at> nwl.cc> writes:
>=20
> > So you do not call init_ring() twice as one may imply when reading =
your
> > first mail? Please provide a complete code sample.
> >=20
>=20
> Yes, I call it twice. The problem is that if I call it twice with the=
 same
> socket_fd, the second time I call it I get the EBUSY error from kerne=
l. I
> have to use two different sockets (two different socket_fd's, therefo=
re) in
> order to workaround this issue.

Which call does produce the EBUSY response, the second setsockopt() or
second mmap() one?
