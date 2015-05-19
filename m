From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Tue, 19 May 2015 15:47:32 -0400
Message-ID: <20150519194731.GK9559@gospo.home.greyhouse.net>
References: <555A8209.5000306@intel.com>
 <20150518.234839.995695850653714769.davem@davemloft.net>
 <555AD11E.5040709@cumulusnetworks.com>
 <20150519.123418.481170679256206928.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, john.r.fastabend@intel.com,
	sfeldma@gmail.com, john.fastabend@gmail.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:33835 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbbESTrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 15:47:35 -0400
Received: by qgez61 with SMTP id z61so9316699qge.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 12:47:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150519.123418.481170679256206928.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2015 at 12:34:18PM -0400, David Miller wrote:
> From: roopa <roopa@cumulusnetworks.com>
> Date: Mon, 18 May 2015 22:58:54 -0700
> 
> > from where I see, with the limitations on these boxes, this requires
> > every app, every `ip route` cmd running on the box to explicitly
> > specify offload when running on this hardware.
> 
> Users know what they are doing, and will ask for a policy change.
> 

Dave,

I'm only writing this as one of the things you said at netdev01 is that
we as a community need to be clear when collectively making decisions
about kernel functionality so there are reasonable 'breadcrumbs' when
someone asks why a decision was made.  So...

Are you actually saying that if users complain loudly enough about the
current behavior (not the change Roopa has proposed) that you would be
open to considering a change the current behavior?

-or-

Are you saying that users who are aware of offload hardware will
begin to make specifically crafted requests (as Roopa suggested with
option 'c') and those requests will force the kernel to behave in
differently that the current default behavior?

-or-

[Insert different conclusion here.]

Thanks,

-andy
