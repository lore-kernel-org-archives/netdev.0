From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH -next] myri10ge: clear NETIF_F_LRO bit directly
Date: Wed, 30 Jun 2010 13:26:22 +0200
Message-ID: <20100630132622.499f41a0@dhcp-lab-109.englab.brq.redhat.com>
References: <20100629163731.1d174b07@dhcp-lab-109.englab.brq.redhat.com>
	<4C2A14CE.3090502@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Amerigo Wang <amwang@redhat.com>,
	Brice Goglin <brice@myri.com>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16133 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752103Ab0F3L0s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 07:26:48 -0400
In-Reply-To: <4C2A14CE.3090502@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Jun 2010 11:44:14 -0400
Andrew Gallatin <gallatin@myri.com> wrote:

> Stanislaw Gruszka wrote:
> > Do not use ethtool_op_set_flags() to clear one bit in ->features.
> > Inform user about disabling LRO.
> 
> Thanks.. That simplifies things nicely.  But was
> direct manipulation of netdev->features ever discouraged,
> or has my use of ethtool_op_{get,set}_flags() to manipulate
> the features always been complete overkill?

It was a bit overkill. Manipulate netdev->features is fine,
many drivers do it.

> > Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> 
> Acked-by: Andrew J. Gallatin <gallatin@myri.com>

Thanks. FYI: Ben Hutchings posted other patch spread over
all drivers: http://patchwork.ozlabs.org/patch/57286/
we most likely will use it to put this myri10ge bits in.

Stanislaw
