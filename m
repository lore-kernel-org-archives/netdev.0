From: Tejun Heo <tj@kernel.org>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Wed, 08 Sep 2010 12:25:54 +0200
Message-ID: <4C8764B2.1070509@kernel.org>
References: <4C358AAA.9080400@kernel.org> <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi> <4C3EF7EA.2040900@nets.rwth-aachen.de> <1279195528.2496.2.camel@edumazet-laptop> <4C3F053F.7090704@nets.rwth-aachen.de> <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi> <4C4467E0.9080907@kernel.org> <alpine.DEB.2.00.1009081232060.26447@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:53955 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959Ab0IHK0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 06:26:12 -0400
In-Reply-To: <alpine.DEB.2.00.1009081232060.26447@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 09/08/2010 11:32 AM, Ilpo J=E4rvinen wrote:
>> Sorry about the delay.  I was traveling last week.  Unfortunately, I
>> don't know whether ->next was NULL on entry or not.  I hacked up the
>> following ugly patch for the next test run.  It should have everythi=
ng
>> which has come up till now + list and hint sanity checking before
>> starting processing them.  I'm planning on deploying it w/ crashdump
>> enabled in several days.  If I've missed something, please let me
>> know.
>=20
> Any news on this one?

Unfortunately, we haven't been able to reproduce the problem anymore.
It could be (but not likely given that none of the debugging messages
is triggering) that I was mistaken and the previously posted fixed the
issue.  The network used by the cluster went through some changes at
the time and there have been issues with packet losses.  Given that
the problem needs packet losses to trigger, it's likely that packet
loss pattern here changed such that the patterns of packet losses
which trigger the problem aren't happening anymore.  (Carsten,
Henning, please feel free to fill in if I'm missing something).

Thanks.

--=20
tejun
