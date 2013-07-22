From: <Narendra_K@Dell.com>
Subject: Re: [patch net-next v2 1/3] net: add ndo to get id of physical port
 of the device
Date: Mon, 22 Jul 2013 04:29:50 -0700
Message-ID: <20130722112921.GA4511@fedora18-dev.oslab.blr.amer.dell.com>
References: <1374342834-10814-1-git-send-email-jiri@resnulli.us>
 <1374342834-10814-2-git-send-email-jiri@resnulli.us>
 <CAJZOPZJiL4hJV4eKKsZrLseJF_sSRjYVsstgT+NLsoeCXWKh_g@mail.gmail.com>
 <20130721210230.GA1558@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <or.gerlitz@gmail.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <stephen@networkplumber.org>,
	<bhutchings@solarflare.com>, <john.r.fastabend@intel.com>
To: <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:5713 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932380Ab3GVLbA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 07:31:00 -0400
In-Reply-To: <20130721210230.GA1558@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 22, 2013 at 02:32:30AM +0530, Jiri Pirko wrote:
> 
> Sun, Jul 21, 2013 at 10:26:32PM CEST, or.gerlitz@gmail.com wrote:
> >On Sat, Jul 20, 2013 at 8:53 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> >>
> >> This patch adds a ndo for getting physical port of the device. Driver
> >> which is aware of being virtual function of some physical port should
> >> implement this ndo.
> >
> >
> >Do you mean virtual function literally?  that is in the PCI IOV aspect?
> 
> This is applicable not only for IOV, nbut for other solutions (NPAR,
> multichannel) as well. Basically if there is possible to have multiple
> netdevs on the single hw port.

I think it would be useful to include this information in the commit
message.

-- 
With regards,
Narendra K
Linux Engineering
Dell Inc.
