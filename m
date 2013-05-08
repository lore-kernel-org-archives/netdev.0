From: Cong Wang <amwang@redhat.com>
Subject: Re: Regression: too many packets with incorrect checksum
Date: Wed, 08 May 2013 20:22:23 +0800
Message-ID: <1368015743.3115.12.camel@cr0>
References: <1368013888.3115.9.camel@cr0> <518A41CA.3030804@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: PJ Waskiewicz <peter.p.waskiewicz.jr@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754312Ab3EHMWa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 May 2013 08:22:30 -0400
In-Reply-To: <518A41CA.3030804@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-08 at 05:15 -0700, PJ Waskiewicz wrote:
> On 5/8/2013 4:51 AM, Cong Wang wrote:
> > Hi, all
> >
> > The latest -net tree has some regression, I saw too many packets with
> > incorrect checksum from tcpdump inside a KVM guest, see the bottom.
> > (firewall is turned off on both sides.)
> >
> > It seems this is not related with drivers, I tried virtio and e1000,
> > both have the same problem. And UDP has the problem too. But turning off
> > tx-checksum by `ethtool -K eth0 tx off` makes the problem disappear
> > (just turning off TSO or GSO doesn't make any difference).
> >
> > I can provide other information if you need.
> 
> Reproduce on bare metal, non-KVM?
> 

Sorry that I don't have env or time to test it on non-KVM, because my
kernel config is specific to KVM and kicks out all modules.
