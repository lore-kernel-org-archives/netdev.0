From: PJ Waskiewicz <peter.p.waskiewicz.jr@linux.intel.com>
Subject: Re: Regression: too many packets with incorrect checksum
Date: Wed, 08 May 2013 05:15:06 -0700
Message-ID: <518A41CA.3030804@linux.intel.com>
References: <1368013888.3115.9.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64437 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753861Ab3EHMPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 May 2013 08:15:08 -0400
In-Reply-To: <1368013888.3115.9.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/8/2013 4:51 AM, Cong Wang wrote:
> Hi, all
>
> The latest -net tree has some regression, I saw too many packets with
> incorrect checksum from tcpdump inside a KVM guest, see the bottom.
> (firewall is turned off on both sides.)
>
> It seems this is not related with drivers, I tried virtio and e1000,
> both have the same problem. And UDP has the problem too. But turning off
> tx-checksum by `ethtool -K eth0 tx off` makes the problem disappear
> (just turning off TSO or GSO doesn't make any difference).
>
> I can provide other information if you need.

Reproduce on bare metal, non-KVM?

-PJ
