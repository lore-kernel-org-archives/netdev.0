From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: pktgen
Date: Sat, 27 Nov 2004 14:53:54 +0100
Message-ID: <20041127135354.GA24617@xi.wantstofly.org>
References: <20041111233507.GA3202@xi.wantstofly.org> <20041124161848.GA18059@xi.wantstofly.org> <16804.48120.375307.718766@robur.slu.se> <20041124170948.GC18059@xi.wantstofly.org> <16804.60621.990421.525393@robur.slu.se> <20041125030450.GA24417@xi.wantstofly.org> <16805.40983.937641.670275@robur.slu.se> <20041127002841.GA17184@xi.wantstofly.org> <20041127004325.GA17401@xi.wantstofly.org> <16808.28005.74903.881087@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16808.28005.74903.881087@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Nov 27, 2004 at 01:04:53PM +0100, Robert Olsson wrote:

> 60	825789
> 64	748975
> 68	729149
> 72	719721
> 76	720204
> 80	720127
> 84	702722
> 88	702799
> 92	705107
> 96	701711
> 100	703858
> 104	692120
> 108	696139
> 112	708936
> 116	697780
> 120	677887
> 124	678158
> 128	739290
> 132	737070
> 136	736894
> 140	737645
> 144	737816
> 148	682755
> 152	648547
> 156	646464

This part is strange.  In my case the pps rate for 132-byte packets is
100kpps lower than for 60-byte packets, in your case the curve is rather
flat.  Perhaps you're CPU-bound here (or hitting some NIC limit.)

Your data is a bit noisy -- can you rerun the test for the 60-200 byte
packet range but using 10M packets per run instead of 1M?


> 160	679270

>From this point onwards your HW can saturate the pipe, this is the
boring part of the graph.


thanks,
Lennert
