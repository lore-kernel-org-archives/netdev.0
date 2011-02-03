From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: sending IP pkgs form user space on a specific interface?
Date: Thu, 3 Feb 2011 23:14:30 +0100
Message-ID: <OF72446498.F31B6A78-ONC125782C.00794F9B-C125782C.007A2D64@transmode.se>
References: <OFAEE2A3EA.1C3F2C8A-ONC125782C.0077F327-C125782C.007872C6@transmode.se> <4D4B2649.40404@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:52526 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753561Ab1BCWOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 17:14:32 -0500
In-Reply-To: <4D4B2649.40404@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> wrote on 2011/02/03 23:03:53:
> From: Ben Greear <greearb@candelatech.com>
> To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> Cc: netdev@vger.kernel.org
> Date: 2011/02/03 23:03
> Subject: Re: sending IP pkgs form user space on a specific interface?
>
> On 02/03/2011 01:55 PM, Joakim Tjernlund wrote:
> >
> > Is there a way to specify what I/F a IP pkg should be sent
> > out on?
> >
> > I have multiple ppp I/Fs with the same local and remote address
> > and I need to specify what interface to send OSPF protocol
> > messages to.
>
> Check out SO_BINDTODEVICE.

Thanks, can do setsockopt(s, SOL_SOCKET, SO_BINDTODEVICE, ..) for
each I/Fs I need tx pkgs over?
How do I unbind to any I/F?

If possible, I would like to specify the I/F in the pkg overhead.

   Jocke

