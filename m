From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH 5/5] tcp: skip cwnd moderation in TCP_CA_Open in tcp_try_to_open
Date: Mon, 28 Nov 2011 12:33:12 -0800
Message-ID: <CAK6E8=dfjZ0tGnihL8cvrg0J=trj2UdB5s3ry+TvdG9Yhzf9jA@mail.gmail.com>
References: <alpine.DEB.2.00.1111201024080.22397@melkinpaasi.cs.helsinki.fi>
 <CAK6E8=cNBCJbQs9dKcOwU1yZMC6czgMEuZt4Ubt=t-kBzHfFmw@mail.gmail.com>
 <alpine.DEB.2.00.1111221146060.31705@wel-95.cs.helsinki.fi>
 <20111127.190120.2116987138205753451.davem@davemloft.net> <CADVnQykp47igdNbN68nbdd4SzaPoDCVTX-bDog4MDesWBbv9MA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, nanditad@google.com, therbert@google.com
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:52934 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065Ab1K1Ude (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 15:33:34 -0500
Received: by qadb14 with SMTP id b14so4083848qad.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 12:33:33 -0800 (PST)
In-Reply-To: <CADVnQykp47igdNbN68nbdd4SzaPoDCVTX-bDog4MDesWBbv9MA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2011 at 9:35 AM, Neal Cardwell <ncardwell@google.com> wrote:
> On Sun, Nov 27, 2011 at 7:01 PM, David Miller <davem@davemloft.net> wrote:
>> I'm apply this patch to net-next now, but Neil and Yucheng are on the hook
>> to fully look into the issues Ilpo has raised.
>
> Thanks! We will spend some time looking into these issues.
>
Ilpo do you know any report on these types of cheating? I did some
literature search but didn't find any.

If the receiver simply responds DSACK on good (non-spurious)
retransmits, the sender may increase dupthresh (tp->reordering) and
slows down triggering fast-recovery? given the connection has real
losses, the receiver may end up shooting his feet.
