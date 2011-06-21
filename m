From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Tue, 21 Jun 2011 14:25:20 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1106211423400.17529@wel-95.cs.helsinki.fi>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com> <BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com> <BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com> <201104271157.49386.carsten@wolffcarsten.de> <BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
 <D0D2412D-2D30-4051-B346-32D20858BC92@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dominik Kaspar <dokaspar.ietf@gmail.com>,
	Carsten Wolff <carsten@wolffcarsten.de>,
	John Heffner <johnwheffner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: Alexander Zimmermann <zimmermann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35611 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754752Ab1FULZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 07:25:22 -0400
In-Reply-To: <D0D2412D-2D30-4051-B346-32D20858BC92@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Apr 2011, Alexander Zimmermann wrote:

> Hi,
> 
> Am 27.04.2011 um 18:22 schrieb Dominik Kaspar:
> 
> > Hi Carsten,
> > 
> > Thanks for your feedback. I made some new tests with the same setup of
> > packet-based forwarding over two emulated paths (600 KB/s, 10 ms) +
> > (400 KB/s, 100 ms). In the first experiments, which showed a step-wise
> > adaptation to reordering, SACK, DSACK, and Timestamps were all
> > enabled. In the experiments, I individually disabled these three
> > mechanisms and saw the following:
> > 
> > - Disabling timestamps causes TCP to never adjust to reordering at all.
> 
> Reordering detection with DSACK is broken in Linux. We will fix that in
> a couple of weeks...
> 
> > - Disabling SACK allows TCP to adapt very rapidly ("perfect" aggregation!).
> 
> If you disable SACK, you will use the NewReno detection

Which probably has some reordering over-estimate bugs on its own... 
(but I've forgotten details of my suspicion long time ago so please don't 
ask for the them).

-- 
 i.
