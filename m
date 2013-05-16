From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Single socket with TX_RING and RX_RING
Date: Thu, 16 May 2013 13:14:04 +0200
Message-ID: <5194BF7C.2040303@redhat.com>
References: <loom.20130515T144941-798@post.gmane.org> <20130515224452.7CAA6224C4@mail.nwl.cc> <loom.20130516T111446-437@post.gmane.org> <20130516104541.GB18282@orbit.nwl.cc> <loom.20130516T125157-378@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, phil@nwl.cc
To: =?ISO-8859-1?Q?Ricardo_Tub=EDo?= <rtpardavila@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7925 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752226Ab3EPLOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 07:14:31 -0400
In-Reply-To: <loom.20130516T125157-378@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/2013 01:01 PM, Ricardo Tub=EDo wrote:
> Phil Sutter <phil <at> nwl.cc> writes:
>
>> So you do not call init_ring() twice as one may imply when reading y=
our
>> first mail? Please provide a complete code sample.
>
> Yes, I call it twice. The problem is that if I call it twice with the=
 same
> socket_fd, the second time I call it I get the EBUSY error from kerne=
l. I
> have to use two different sockets (two different socket_fd's, therefo=
re) in
> order to workaround this issue.
>
> The code I use for calling "init_ring" is the one below. If in functi=
on
> "init_rings", instead of using two different sockets (rx_socket_fd an=
d
> tx_socket_fd), I use a single socket, I get the EBUSY error from kern=
el.

Ricardo, haven't we already been trough this that this way it cannot wo=
rk?

This is not what we suggested in earlier mails.

Also, why do you keep sending your answers only to netdev without keepi=
ng
others in CC?
