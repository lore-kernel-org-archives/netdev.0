From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHSET net-next v3 00/07] Support for byte queue limits on
 various drivers
Date: Mon, 21 Oct 2013 10:53:59 +0100
Message-ID: <1382349239.25689.14.camel@deadeye.wl.decadent.org.uk>
References: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
	 <87iowrtzlz.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tino Reichardt <milky-kernel@mcmilk.de>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64844 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753015Ab3JUJyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 05:54:04 -0400
In-Reply-To: <87iowrtzlz.fsf@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-10-20 at 14:13 -0700, Andi Kleen wrote:
> Tino Reichardt <milky-kernel@mcmilk.de> writes:
> >
> > Since not all of them are fully tested by now, I added an bql_disable
> > module parameter, which can be used to disable the BQL code.
> >
> > "if (likely(bql_disable == false))" was replaced by
> > "if (unlikely(bql_disable))" ...
> 
> If it's untested it should probably be disabled by default,
> until someone tests it.

Right, and module parameters are a pretty poor way to control this.

(It should already be possible to disable BQL through sysfs, anyway.
But there is a distinct lack of documentation in the kernel tree.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
