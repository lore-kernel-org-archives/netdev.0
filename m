From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 00/12] Convert more drivers to ethtool
 set_phys_id
Date: Mon, 04 Apr 2011 21:28:34 +0100
Message-ID: <1301948914.2807.45.camel@bwh-desktop>
References: <20110404184340.604594357@linuxplumber.net>
	 <BANLkTimfFPEhr4GozxBZB5Pc-LGXWfGTPQ@mail.gmail.com>
	 <20110404131459.793f67fc@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:20322 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755401Ab1DDU2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 16:28:37 -0400
In-Reply-To: <20110404131459.793f67fc@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-04 at 13:14 -0700, Stephen Hemminger wrote:
> On Mon, 4 Apr 2011 12:53:14 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
> > On Mon, Apr 4, 2011 at 11:43, Stephen Hemminger <shemminger@vyatta.com> wrote:
> > > Did a bunch of the easy drivers to convert.
> > >
> > >
> > 
> > I have added patches 3-9 (Intel driver conversions) to my queue of
> > patches.  Thanks Stephen.
> 
> I changed the behaviour of igbvf for 'ethtool -p' to return not supported.
> This seems correct, but it may break somebody who has some weird script running
> in a virt environment.

Surely it should be connected to a virtual LED.  Doesn't virt-manager
have those yet? ;-)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

