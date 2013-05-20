From: Paul Chavent <paul.chavent@fnac.net>
Subject: Re: Single socket with TX_RING and RX_RING
Date: Mon, 20 May 2013 22:54:31 +0200
Message-ID: <519A8D87.6080409@fnac.net>
References: <loom.20130515T144941-798@post.gmane.org> <20130515224452.7CAA6224C4@mail.nwl.cc> <loom.20130516T111446-437@post.gmane.org> <20130516104541.GB18282@orbit.nwl.cc> <loom.20130516T125157-378@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Ricardo_Tub=EDo?= <rtpardavila@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb2-g21.free.fr ([212.27.42.10]:48394 "EHLO
	smtpfb2-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756561Ab3ETUyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 16:54:02 -0400
Received: from smtp5-g21.free.fr (smtp5-g21.free.fr [212.27.42.5])
	by smtpfb2-g21.free.fr (Postfix) with ESMTP id 5F104D1A1A0
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 22:53:54 +0200 (CEST)
In-Reply-To: <loom.20130516T125157-378@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/2013 01:01 PM, Ricardo Tub=EDo wrote:
> Phil Sutter <phil <at> nwl.cc> writes:
>
>> So you do not call init_ring() twice as one may imply when reading y=
our
>> first mail? Please provide a complete code sample.
>>
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
>
> Hope this clarifies, Cardo.

Hi.

As stated before, you should call mmap only once.

Paul.
