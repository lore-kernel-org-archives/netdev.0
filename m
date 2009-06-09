From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2 1/2] tc_core: Use double in tc_core_time2tick()
Date: Wed, 10 Jun 2009 00:20:41 +0200
Message-ID: <20090609222041.GB2893@ami.dom.local>
References: <20090609080536.GD5237@ff.dom.local> <4A2E6BA4.30002@trash.net> <20090609215425.GA2893@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Antonio Almeida <vexwek@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <devik@cdi.cz>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:18757 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbZFIWUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 18:20:53 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1144403fga.17
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2009 15:20:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090609215425.GA2893@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2009 at 11:54:25PM +0200, Jarek Poplawski wrote:
> On Tue, Jun 09, 2009 at 04:03:16PM +0200, Patrick McHardy wrote:
...
> > It seems inconsistent to have the time2tick() function take a
> > double, but return an unsigned from tick2time(). If we're going
> > to change this, please keep them symetrical (you could even use
> > floor() in tick2time() to make it more explicit).
...
> tc_core_tick2time() is used differently; it usually gets integers, to
> show them as time. But even if not so, we have division here. So, I'm
> not sure it's really needed, but if you confirm I'll do it in a
> separate patch.

OOPS! I argued for double as argument, but you're right tick2time()
should return double for consistency. I'll send a separate patch.

Sorry,
Jarek P.
