From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH net-next 0/7] mlx4: Add SRIOV support for RoCE
Date: Tue, 11 Mar 2014 09:55:42 -0500
Message-ID: <1394549742.2377.2.camel@dcbw.local>
References: <1394376844-12812-1-git-send-email-ogerlitz@mellanox.com>
	 <1394474882.28217.6.camel@dcbw.local> <531E0D04.1040404@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, amirv@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9526 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575AbaCKOxw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 10:53:52 -0400
In-Reply-To: <531E0D04.1040404@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 21:05 +0200, Or Gerlitz wrote:
> On 10/03/2014 20:08, Dan Williams wrote:
> >
> > While I could be wrong, I think the phys_port_id sysfs attribute is
> > relevant here.  This attribute should be set for any VF so that
> > userspace clients can determine that two VFs are backed by the same PF,
> > which of course means they share bandwidth and thus some operations
> > cannot be performed.  This is implemented with ndo_get_phys_port_id.
> >
> Indeed, and this is supported for mlx4 through the sequence of these 
> commits\\
> 
> 84c8640 net/mlx4_en: Implement ndo_get_phys_port_id
> 8e1a28e net/mlx4_core: Expose physical port id as PF/VF capability
> eb17711 net/mlx4_core: Introduce nic_info new flag in QUERY_FUNC_CAP
> 73e74ab net/mlx4_core: Rename QUERY_FUNC_CAP fields
> 7b25d81 net/mlx4_core: Remove zeroed out of explicit QUERY_FUNC_CAP fields

Ah!  My mistake, I didn't see that.  Carry on :)

Dan
