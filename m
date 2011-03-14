From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH NEXT 2/2] netxen: support for GbE port settings
Date: Mon, 14 Mar 2011 22:44:08 +0000
Message-ID: <1300142648.2584.76.camel@bwh-desktop>
References: <1299837003-5616-3-git-send-email-amit.salecha@qlogic.com>
	 <20110314.151531.233692938.davem@davemloft.net>
	 <1300141822.2584.71.camel@bwh-desktop>
	 <20110314.153240.241445951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com,
	sony.chacko@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:16419 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715Ab1CNWoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:44:12 -0400
In-Reply-To: <20110314.153240.241445951.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-14 at 15:32 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 14 Mar 2011 22:30:22 +0000
> 
> > On Mon, 2011-03-14 at 15:15 -0700, David Miller wrote:
> >> From: Amit Kumar Salecha <amit.salecha@qlogic.com>
> >> Date: Fri, 11 Mar 2011 01:50:03 -0800
> >> 
> >> > From: Sony Chacko <sony.chacko@qlogic.com>
> >> > 
> >> > o Allow setting speed and auto negotiation parameters for GbE ports.
> >> > o Log an error message to indicate duplex setting is not supported in
> >> >   the hardware currently.
> >> > 
> >> > Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
> >> > Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> >> 
> >> The kernel log is not the place to transmit this information.
> >> 
> >> Please work with Ben Hutchings who is working for ways to report
> >> this to the user in the proper location, via ethtool.
> > 
> > I am?  Well, patches welcome, at least.
> 
> You were discussing a scheme, I think with Intel folks, about letting
> such changes through then making ethtool re-read the settings and see
> which changes were not integrated by the driver.
> 
> Then you'd emit a diagnostic from ethtool over stderr to report any
> such discrepencies.

Only for offload settings, where the API makes it clear which flags the
user is deliberately setting and the kernel or driver can reasonably fix
up others.  For link settings, that isn't clear, and drivers should
simply reject invalid combinations.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

