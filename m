From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch 2/2] mlx4: add dynamic LRO disable support
Date: Fri, 04 Jun 2010 09:56:21 +0800
Message-ID: <4C085D45.6040001@redhat.com>
References: <20100603034303.5305.55552.sendpatchset@localhost.localdomain>	 <20100603034312.5305.61000.sendpatchset@localhost.localdomain> <1275568622.2870.89.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert.xu@redhat.com, nhorman@redhat.com,
	sgruszka@redhat.com, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53178 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757042Ab0FDBwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jun 2010 21:52:22 -0400
In-Reply-To: <1275568622.2870.89.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/10 20:37, Ben Hutchings wrote:
> On Wed, 2010-06-02 at 23:39 -0400, Amerigo Wang wrote:
>> This patch adds dynamic LRO diable support for mlx4 net driver.
>> It also fixes a bug of mlx4, which checks NETIF_F_LRO flag in rx
>> path without rtnl lock.
> [...]
>
> Is that flag test actually unsafe - and if so, how is testing num_lro
> any better?  Perhaps access to net_device::features should be wrapped
> with ACCESS_ONCE() to ensure that reads and writes are atomic.
>

At least, I don't find there is any race with 'num_lro', thus
no lock is needed.

Thanks.
