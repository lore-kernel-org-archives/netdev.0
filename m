From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Thu, 19 Nov 2015 01:56:08 +0100
Message-ID: <20151119005608.GB4882@electric-eye.fr.zoreil.com>
References: <20130309064647.GC4984@marvin.atrad.com.au>
 <20130311000216.GA31808@zoreil.com>
 <20130405001526.GC19253@marvin.atrad.com.au>
 <20151117015605.GI22941@marvin.atrad.com.au>
 <20151117232108.GC3362@electric-eye.fr.zoreil.com>
 <20151118050919.GR25216@marvin.atrad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jonathan Woithe <jwoithe@atrad.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55854 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756214AbbKSA4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 19:56:17 -0500
Content-Disposition: inline
In-Reply-To: <20151118050919.GR25216@marvin.atrad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Woithe <jwoithe@atrad.com.au> :
[...]
> I could try.  What's the most reliable way to determine this?  Use regular
> ethtool queries about the time of the failures?

If you are neither space nor cpu constrained:

while : ; do
	echo $(date +%s.%N):$(ethtool -d eth0 raw on | base64 -w 0):$(ethtool -S eth0 | base64 -w 0)
	sleep 1
done > gloubi

Expect 2.5~3Mo per hour.

(I like gnuplot with lots of points and repetitive patterns)

-- 
Ueimor
