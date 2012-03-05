From: Mitar <mmitar@gmail.com>
Subject: Re: Ethernet-over-UDP virtual network interface
Date: Tue, 6 Mar 2012 00:58:44 +0100
Message-ID: <CAKLmikOVydmSJEBWwDc=Jv4XPMi3dsS+Pn9=BP_bBePD0L7K8A@mail.gmail.com>
References: <CAKLmikOBPB7rTZu2EfK26=3AhOQUR8xg8n4ySUKRMFmBkC1J3g@mail.gmail.com>
	<20120304170101.GH21526@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Nejc Skoberne <nejc@skoberne.net>,
	Jernej Kos <kostko@unimatrix-one.org>, gw.2012@tnode.com
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:39147 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757961Ab2CEX6p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 18:58:45 -0500
Received: by vcqp1 with SMTP id p1so3923547vcq.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 15:58:44 -0800 (PST)
In-Reply-To: <20120304170101.GH21526@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Sun, Mar 4, 2012 at 6:01 PM, Benjamin LaHaise <bcrl@kvack.org> wrote=
:
> Why not use L2TP? =C2=A0It can operate over UDP (v2 or v3) or directl=
y over IP
> if needed (v3). =C2=A0L2TPv3 also supports ethernet pseudo-wires.

I would like something state-less. I see L2TPv3 has support for
unmanaged tunnels, but they still require tunnel id and session id
what (if I assume that they have to be unique) makes it useless for
our case. We have (if I simplify) a star-shaped topology with a
central server in the middle. To the central server WiFi nodes
(hundreds of them) connect. But we do not really want to require from
a central server to know each WiFi node and prepare its tunnel
endpoint for each node. We would just like that there would be virtual
interface and UDP port and any packet send to the UDP port would be
decapsulated and output through that virtual interface. The only thing
which we would have to make sure is that each WiFi node has a virtual
interface with unique MAC address.


Mitar
