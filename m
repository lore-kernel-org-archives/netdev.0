From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6 00/12] Convert more drivers to ethtool
 set_phys_id
Date: Mon, 4 Apr 2011 13:14:59 -0700
Message-ID: <20110404131459.793f67fc@nehalam>
References: <20110404184340.604594357@linuxplumber.net>
	<BANLkTimfFPEhr4GozxBZB5Pc-LGXWfGTPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44677 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755590Ab1DDUPC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 16:15:02 -0400
In-Reply-To: <BANLkTimfFPEhr4GozxBZB5Pc-LGXWfGTPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Apr 2011 12:53:14 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> On Mon, Apr 4, 2011 at 11:43, Stephen Hemminger <shemminger@vyatta.com> wrote:
> > Did a bunch of the easy drivers to convert.
> >
> >
> 
> I have added patches 3-9 (Intel driver conversions) to my queue of
> patches.  Thanks Stephen.

I changed the behaviour of igbvf for 'ethtool -p' to return not supported.
This seems correct, but it may break somebody who has some weird script running
in a virt environment.
