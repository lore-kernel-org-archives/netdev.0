From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Wed, 8 Sep 2010 13:34:56 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1009081329140.26447@wel-95.cs.helsinki.fi>
References: <4C358AAA.9080400@kernel.org> <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi> <4C3EF7EA.2040900@nets.rwth-aachen.de> <1279195528.2496.2.camel@edumazet-laptop> <4C3F053F.7090704@nets.rwth-aachen.de>
 <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi> <4C4467E0.9080907@kernel.org> <alpine.DEB.2.00.1009081232060.26447@wel-95.cs.helsinki.fi> <4C8764B2.1070509@kernel.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1788809282-1283942096=:26447"
Cc: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46273 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954Ab0IHKe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 06:34:58 -0400
In-Reply-To: <4C8764B2.1070509@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1788809282-1283942096=:26447
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 8 Sep 2010, Tejun Heo wrote:

> On 09/08/2010 11:32 AM, Ilpo Järvinen wrote:
> >> Sorry about the delay.  I was traveling last week.  Unfortunately, I
> >> don't know whether ->next was NULL on entry or not.  I hacked up the
> >> following ugly patch for the next test run.  It should have everything
> >> which has come up till now + list and hint sanity checking before
> >> starting processing them.  I'm planning on deploying it w/ crashdump
> >> enabled in several days.  If I've missed something, please let me
> >> know.
> > 
> > Any news on this one?
> 
> Unfortunately, we haven't been able to reproduce the problem anymore.

With my debug patch or not at all?

> It could be (but not likely given that none of the debugging messages
> is triggering) that I was mistaken and the previously posted fixed the
> issue. The network used by the cluster went through some changes at
> the time and there have been issues with packet losses.  Given that
> the problem needs packet losses to trigger, it's likely that packet
> loss pattern here changed such that the patterns of packet losses
> which trigger the problem aren't happening anymore.  (Carsten,
> Henning, please feel free to fill in if I'm missing something).

That might well be true, however, you're already a second guy who 
cannot reproduce it with the debug patch so I would not rule out other 
possibilities unless you've tried without debug patch too since the 
changes?


-- 
 i.
--8323329-1788809282-1283942096=:26447--
