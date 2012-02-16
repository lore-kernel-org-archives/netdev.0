From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Thu, 16 Feb 2012 13:19:58 -0500
Message-ID: <CADVnQyknYYaduh4nnc27=oGofBqpExJzqA-ToXufZxbtm0xs6Q@mail.gmail.com>
References: <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120216.120149.437368615973561397.davem@davemloft.net>
	<CADVnQykm==YJZbdCbLxgJ236jD2yN0xT99gmeYX-FGnyBvfEGA@mail.gmail.com>
	<1461927.R8CTCUdqT9@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:43147 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127Ab2BPSUA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 13:20:00 -0500
Received: by qadc10 with SMTP id c10so4711198qad.19
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2012 10:20:00 -0800 (PST)
In-Reply-To: <1461927.R8CTCUdqT9@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2012 at 12:54 PM,  <alekcejk@googlemail.com> wrote:

> Looks like =A0"ethtool -k eth0" shows the same with both kernels:
>
> Offload parameters for eth0:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: off
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off
> rx-vlan-offload: off
> tx-vlan-offload: off
> ntuple-filters: off
> receive-hashing: off

Great. Thanks, Alexey.

I still think it would be useful to have these three pieces of data
for a slow/3.2.x transfer (from a geographically distant server) if
you have a sec:

- tcpdump of first 300 or so packets to see SYN/SYNACK options and RTT

- tcpdump of _last_ 300 or so packets, to see the steady-state dynamics
=A0with receiver window and packet inter-arrival times

- summary of overall throughput wget sees on that transfer

This should help establish whether the receiver window is really the
limiting factor in the slow cases.

neal
