From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 1/7] devlink: No need for this self-assignment
Date: Fri, 18 Aug 2017 12:20:24 +0200
Message-ID: <20170818102024.GF10864@orbyte.nwl.cc>
References: <20170817170931.24089-1-phil@nwl.cc>
 <20170817170931.24089-2-phil@nwl.cc>
 <20170817194850.GA24011@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:56443 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750812AbdHRKUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 06:20:25 -0400
Content-Disposition: inline
In-Reply-To: <20170817194850.GA24011@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 17, 2017 at 09:48:50PM +0200, Jiri Pirko wrote:
> Thu, Aug 17, 2017 at 07:09:25PM CEST, phil@nwl.cc wrote:
> >dl_argv_handle_both() will either assign to handle_bit or error out in
> >which case the variable is not used by the caller.
> 
> I'm pretty sure that I did this to silence the compiler. If the compiler
> bug is fixed now, good.

That might depend on the compiler you used, so maybe you just want to
give it a try in your environment? If it still happens, we can keep this
self-assignment of course since it shouldn't harm.

Thanks, Phil
