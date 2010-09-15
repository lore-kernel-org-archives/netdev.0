From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: E1000E/82567LM-3: link reported up too soon
Date: Wed, 15 Sep 2010 17:34:30 +0200
Message-ID: <87pqwff2bd.fsf@small.ssi.corp>
References: <87eicvi0cz.fsf@small.ssi.corp> <4C90E11B.7020807@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:44200 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753483Ab0IOPdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 11:33:46 -0400
In-Reply-To: <4C90E11B.7020807@hp.com> (Brian Haley's message of "Wed, 15 Sep
	2010 11:07:07 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Brian,

Brian Haley <brian.haley@hp.com> writes:

>> <snip>
>> 
>> I tested it with 2 different 100M/s switches (Cisco Catalyst 2960 and a
>> Planex FX08-Mini) so I guess the switch is not the root of the issue. I
>> came to the conclusion that the link is reported up too soon by the
>> driver.
>> 
>> Because the first packets are losts, the result is that address
>> autoconfiguration is delayed by a few seconds as can be seen on
>> following capture on the laptop:
>
> I've seen similar things on various NICs,

I remember I add the same kind of issue on a broadcom chip on a dell
D600 but had no time to investigate at that time. Did you notice the
problem for different brands? Do you think those are driver-related
issues or something in common code?
 
> posted a patch last week that unfortunately had other bad
> side-effects.  When I have time I'll work on it again, but I'd also be
> curious if there's something that can be done at the driver level to
> help out, since it seemed like part of the problem is that the link-UP
> came before the device was actually able to transmit packets, so the
> DAD was lost.

I am not familiar with e1000e code but as I said previously I'd be happy
to test patches to help determine precisely where the packet gets lost
and why.

Cheers,

a+
