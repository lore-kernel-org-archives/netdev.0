From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Sat, 16 May 2009 10:31:58 +0200
Message-ID: <20090516083158.GA3013@ami.dom.local>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com> <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:39361 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822AbZEPIcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2009 04:32:35 -0400
Received: by bwz22 with SMTP id 22so2293528bwz.37
        for <netdev@vger.kernel.org>; Sat, 16 May 2009 01:32:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2009 at 03:49:31PM +0100, Antonio Almeida wrote:
> Hi!
> I've been using HTB in a Linux bridge and recently I noticed that, fo=
r
> high speed, the configured rate/ceil is not respected as for lower
> speeds.
> I'm using a packet generator/analyser to inject over 950Mpbs, and see
> what returns back to it, in the other side of my bridge. Generated
> packets have 800bytes. I noticed that, for several tc HTB rate/ceil
> configurations the amount of traffic received by the analyser stays
> the same. See this values:
>=20
> HTB conf=A0=A0=A0=A0=A0 Analyser reception
> 476000Kbit=A0=A0=A0 544.260.329
=2E..
> As you can see, class htb 1:108 rate's is 653124Kbit! Much bigger tha=
t
> it's ceil.

Is it for sure there is no gso/tso enabled on this dev (with up to
date ethtool -k)? It would be nice to see also more details like
=2Econfig, ifconfigs before and after the test, tc -s qdisc and bytes/
packet number seen by this analyser, plus maybe some proof you can
obtain such flows with something simpler like tbf. Of course using
the current kernel, even if no difference, would give us more
valuable perspective.

Thanks,
Jarek P.
