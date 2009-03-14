From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to submit
	to upper layer
Date: Sat, 14 Mar 2009 11:15:21 -0700
Message-ID: <65634d660903141115w7e164134ycece307f041e93a9@mail.gmail.com>
References: <65634d660903131459m645eb468y3ad850a1fd56d447@mail.gmail.com>
	 <20090313.151913.21135937.davem@davemloft.net>
	 <65634d660903131724s49009177pdc11005aa76a4b56@mail.gmail.com>
	 <20090313.191951.228619450.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yanmin_zhang@linux.intel.com, bhutchings@solarflare.com,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	jesse.brandeburg@intel.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:37988 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486AbZCNSPa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 14:15:30 -0400
In-Reply-To: <20090313.191951.228619450.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2009 at 7:19 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Tom Herbert <therbert@google.com>
> Date: Fri, 13 Mar 2009 17:24:10 -0700
>
>> Enabling HW multi-queue has somewhat higher CPU
>> utilization though, the extra device interrupt load is not coming fo=
r
>> free. =A0We actually use the HW multi-queue in conjunction with our
>> software steering to get maximum pps (about 20% more).
>
> This is a non-intuitive observation. =A0Using HW multiqueue should be
> cheaper than doing it in software, right?
>

I suppose it may be counter-intuitive, but I am not making a general
claim.  I would only suggest that these software hacks could be a very
good approximation or substitute for hardware functionality.  This is
a generic way to get more performance out of deficient or lower end
NICs.
