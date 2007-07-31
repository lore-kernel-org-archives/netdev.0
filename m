From: jamal <hadi@cyberus.ca>
Subject: Re: fscked clock sources revisited
Date: Mon, 30 Jul 2007 22:14:36 -0400
Message-ID: <1185848076.5162.39.camel@localhost>
References: <1185844239.5162.17.camel@localhost>
	 <20070730.183750.77058266.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:4771 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032AbXGaCO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 22:14:58 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1519054wxd
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2007 19:14:57 -0700 (PDT)
In-Reply-To: <20070730.183750.77058266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-30-07 at 18:37 -0700, David Miller wrote:

> Relatively speaking, the acpi_pm numbers are at least consistent and
> about as much as so as jiffies.  Jiffies numbers are also possibly
> better, at least in part, because of the decreased accuracy and errors
> propagating.

I am not sure jiffies gives innacurate results. It gives the best
performance on the dual xeon i tested on, all the time. Very consistent.
On its accuracy: I was able to validate it With pktgen generating
traffic and some external hardware tool capturing the interpacket gaps
etc.

> tsc acts as expected, since every time your cpu changes power
> management state (which it is going to do dynamically) the TSC
> rates change and thus the accuracy goes into outer-space.

Robert was saying he had even more bizare results with opteron given the
NUMA nature.

> There really isn't much that can be done by any of this.  These issues
> exist because of hardware limitations, nobody bothered to build
> x86/x86_64 systems with a system wide TICK register that is both
> impervious to cpu frequence scaling and also cheap to access.
> 
> So the above is what we basically have to live with :-)

That is a bummer. I am going to test with hpet when i get the chance
and perhaps turn off all the other sources if nothing good comes out; i
need my numbers ;->

cheers,
jamal

