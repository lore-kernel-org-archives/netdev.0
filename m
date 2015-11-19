From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Thu, 19 Nov 2015 17:27:18 +1030
Message-ID: <20151119065718.GT8170@marvin.atrad.com.au>
References: <20130309064647.GC4984@marvin.atrad.com.au>
 <20130311000216.GA31808@zoreil.com>
 <20130405001526.GC19253@marvin.atrad.com.au>
 <20151117015605.GI22941@marvin.atrad.com.au>
 <20151117232108.GC3362@electric-eye.fr.zoreil.com>
 <20151118050919.GR25216@marvin.atrad.com.au>
 <20151119005608.GB4882@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:39715 "EHLO
	server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981AbbKSG51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 01:57:27 -0500
Content-Disposition: inline
In-Reply-To: <20151119005608.GB4882@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015 at 01:56:08AM +0100, Francois Romieu wrote:
> Jonathan Woithe <jwoithe@atrad.com.au> :
> [...]
> > I could try.  What's the most reliable way to determine this?  Use regular
> > ethtool queries about the time of the failures?
> 
> If you are neither space nor cpu constrained:
> 
> while : ; do
> 	echo $(date +%s.%N):$(ethtool -d eth0 raw on | base64 -w 0):$(ethtool -S eth0 | base64 -w 0)
> 	sleep 1
> done > gloubi
> 
> Expect 2.5~3Mo per hour.

We're certainly not disc constrained.  The high speed acquisition takes a
fair bit of CPU but there should still be sufficient free to at least give
the above a go.  I'll run some tests tomorrow and see what transpires.

Regards
  jonathan
