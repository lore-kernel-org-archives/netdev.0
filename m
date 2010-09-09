From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Thu, 9 Sep 2010 13:45:13 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1009091328170.26447@wel-95.cs.helsinki.fi>
References: <4C358AAA.9080400@kernel.org> <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi> <4C3EF7EA.2040900@nets.rwth-aachen.de> <1279195528.2496.2.camel@edumazet-laptop> <4C3F053F.7090704@nets.rwth-aachen.de>
 <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi> <4C4467E0.9080907@kernel.org> <alpine.DEB.2.00.1009081232060.26447@wel-95.cs.helsinki.fi> <4C8764B2.1070509@kernel.org> <alpine.DEB.2.00.1009081329140.26447@wel-95.cs.helsinki.fi>
 <4C88B687.60907@kernel.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-276696241-1284028492=:26447"
Cc: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54096 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644Ab0IIKpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 06:45:15 -0400
In-Reply-To: <4C88B687.60907@kernel.org>
Content-ID: <alpine.DEB.2.00.1009091344300.26447@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-276696241-1284028492=:26447
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1009091344301.26447@wel-95.cs.helsinki.fi>

On Thu, 9 Sep 2010, Tejun Heo wrote:

> On 09/08/2010 12:34 PM, Ilpo Järvinen wrote:
> >> Unfortunately, we haven't been able to reproduce the problem anymore.
> > 
> > With my debug patch or not at all?
> 
> With the ugly merged patch I posted previously in this thread which
> contained debug messages if any of the worked around condition
> triggers.
> 
> >> It could be (but not likely given that none of the debugging messages
> >> is triggering) that I was mistaken and the previously posted fixed the
> >> issue. The network used by the cluster went through some changes at
> >> the time and there have been issues with packet losses.  Given that
> >> the problem needs packet losses to trigger, it's likely that packet
> >> loss pattern here changed such that the patterns of packet losses
> >> which trigger the problem aren't happening anymore.  (Carsten,
> >> Henning, please feel free to fill in if I'm missing something).
> > 
> > That might well be true, however, you're already a second guy who 
> > cannot reproduce it with the debug patch so I would not rule out other 
> > possibilities unless you've tried without debug patch too since the 
> > changes?
> 
> Unfortunately, I can't really tell one way or the other at this point.
> Carsten will be back in a few days.  I'll ask him for more details.

Once you get the info, if not yet done, I'd recommend you try without the 
debug patch (assuming a possible crash isn't too devasting for the actual 
stuff you're doing with the machines :-)). ...If it crashes without, then 
it's time to start looking into compiler versions, etc.

-- 
 i.
--8323329-276696241-1284028492=:26447--
