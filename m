From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 11:32:16 +0400
Message-ID: <20060428073216.GB3378@2ka.mipt.ru>
References: <54AD0F12E08D1541B826BE97C98F99F143B020@NT-SJCA-0751.brcm.ad.broadcom.com> <20060428061054.GD17360@2ka.mipt.ru> <20060428.002027.51369887.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: caitlinb@broadcom.com, kelly@au1.ibm.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58033 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030289AbWD1Hcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 03:32:50 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060428.002027.51369887.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2006 at 12:20:27AM -0700, David S. Miller (davem@davemloft.net) wrote:
> > Btw, how is it supposed to work without header split capabale hardware?
> 
> I do not see header splitting as a requirement, let the raw
> headers sit in the user queue and provide an offset to the data.
> All of this page alignment stuff is unnecessary complexity.
> 
> I know you think applications are too dumb to be expected to handle
> these kinds of things, but how many apps do you expect to convert over
> to these new interfaces?
> 
> The ones that matter will, and great care will be made by the
> programmer who does this.

Ugh, so it will not ring buffer of data _flow_, but ring buffer of
(header+data) packets.

Definitely, userspace application must be very smart to deal with 
ip/tcp/option headers...

-- 
	Evgeniy Polyakov
