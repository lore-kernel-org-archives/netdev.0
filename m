From: "SANGTAE HA" <sangtae.ha@gmail.com>
Subject: Re: SACK scoreboard
Date: Wed, 9 Jan 2008 13:14:22 -0500
Message-ID: <649aecc70801091014u50d1be26ndf5e59e0492ce9cd@mail.gmail.com>
References: <20080108.144456.173014334.davem@davemloft.net>
	 <p73sl17pwfy.fsf@bingen.suse.de> <47844D1C.1060706@psc.edu>
	 <20080108.224144.234253941.davem@davemloft.net>
	 <4784E090.8080303@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, andi@firstfloor.org,
	ilpo.jarvinen@helsinki.fi, lachlan.andrew@gmail.com,
	netdev@vger.kernel.org, quetchen@caltech.edu
To: "John Heffner" <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:60072 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754140AbYAISOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 13:14:25 -0500
Received: by wx-out-0506.google.com with SMTP id h31so182934wxd.4
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2008 10:14:24 -0800 (PST)
In-Reply-To: <4784E090.8080303@psc.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 9, 2008 9:56 AM, John Heffner <jheffner@psc.edu> wrote:
> >> I also wonder how much of a problem this is (for now, with window sizes
> >> of order 10000 packets.  My understanding is that the biggest problems
> >> arise from O(N^2) time for recovery because every ack was expensive.
> >> Have current tests shown the final ack to be a major source of problems?
> >
> > Yes, several people have reported this.
>
> I may have missed some of this.  Does anyone have a link to some recent
> data?

I had some testing on this a month ago.
A small set of recent results with linux 2.6.23.9 are at
http://netsrv.csc.ncsu.edu/net-2.6.23.9/sack_efficiency
One of serious cases with a large number of packet losses (initial
loss is around 8000 packets) is at
http://netsrv.csc.ncsu.edu/net-2.6.23.9/sack_efficiency/600--TCP-TCP-NONE--400-3-1.0--1000-120-0-0-1-1-5-500--1.0-0.5-133000-73-3000000-0.93-150--3/

Also, there is a comparison among three Linux kernels (2.6.13,
2.6.18-rc4, 2.6.20.3) at
http://netsrv.csc.ncsu.edu/wiki/index.php/Efficiency_of_SACK_processing

Sangtae
