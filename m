From: Andi Kleen <ak@suse.de>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 19 Jun 2006 17:24:31 +0200
Message-ID: <200606191724.31305.ak@suse.de>
References: <4492D5D3.4000303@atmos.washington.edu> <44948EF6.1060201@atmos.washington.edu> <Pine.LNX.4.61.0606191638550.23553@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Harry Edmon <harry@atmos.washington.edu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:62860 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932513AbWFSPYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2006 11:24:40 -0400
To: Jesper Dangaard Brouer <hawk@diku.dk>
In-Reply-To: <Pine.LNX.4.61.0606191638550.23553@ask.diku.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> If you use "pmtmr" try to reboot with kernel option "clock=tsc".

That's dangerous advice - when the system choses not to use
TSC it often has a reason.

> 
> On my Opteron AMD system i normally can route 400 kpps, but with 
> timesource "pmtmr" i could only route around 83 kpps.  (I found the timer 
> to be the issue by using oprofile).

Unless you're using packet sniffing or any other application
that requests time stamps on a socket then the timer shouldn't 
make much difference. Incoming packets are only time stamped
when someone asks for the timestamps.

-Andi
