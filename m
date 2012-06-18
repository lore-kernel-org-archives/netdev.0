From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: unstable 10GBE performance with recent kernels (> 3.0.X)
Date: Mon, 18 Jun 2012 12:25:43 +0200
Message-ID: <1340015143.7491.855.camel@edumazet-glaptop>
References: <4FDEF34C.808@profihost.ag>
	 <1340012706.7491.770.camel@edumazet-glaptop>
	 <4FDEFD55.7010204@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40741 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972Ab2FRKZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 06:25:49 -0400
Received: by eeit10 with SMTP id t10so1498206eei.19
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 03:25:48 -0700 (PDT)
In-Reply-To: <4FDEFD55.7010204@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-18 at 12:05 +0200, Stefan Priebe - Profihost AG wrote:
> Am 18.06.2012 11:45, schrieb Eric Dumazet:
> > On Mon, 2012-06-18 at 11:22 +0200, Stefan Priebe - Profihost AG wrote:
> >> Hello list,
> >>
> >> i've discovered very unstable 10GBE performance using recent kernels.
> >> I'm using some optimized settings mentioned by intel here
> >> (part:Improving Performance):
> >> http://downloadmirror.intel.com/5874/eng/README.txt
> >>
> > like what settings ?
> 
> Sorry these ones:
> http://pastebin.com/raw.php?i=J2XRFAjD
> 

I would remove all this (pretty old and obsolete) stuff and use standard
params.

Only thing you could do is :

ethtool -K eth2 ntuple on

on both machines
