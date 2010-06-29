From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH -next] myri10ge: clear NETIF_F_LRO bit directly
Date: Tue, 29 Jun 2010 11:44:14 -0400
Message-ID: <4C2A14CE.3090502@myri.com>
References: <20100629163731.1d174b07@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Amerigo Wang <amwang@redhat.com>,
	Brice Goglin <brice@myri.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1914 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752399Ab0F2QP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 12:15:29 -0400
In-Reply-To: <20100629163731.1d174b07@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislaw Gruszka wrote:
> Do not use ethtool_op_set_flags() to clear one bit in ->features.
> Inform user about disabling LRO.

Thanks.. That simplifies things nicely.  But was
direct manipulation of netdev->features ever discouraged,
or has my use of ethtool_op_{get,set}_flags() to manipulate
the features always been complete overkill?

> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>

Acked-by: Andrew J. Gallatin <gallatin@myri.com>


Thanks,

Drew

