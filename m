From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 0/7] mlx4: Add SRIOV support for RoCE
Date: Mon, 10 Mar 2014 21:05:40 +0200
Message-ID: <531E0D04.1040404@mellanox.com>
References: <1394376844-12812-1-git-send-email-ogerlitz@mellanox.com> <1394474882.28217.6.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<roland@kernel.org>, <jackm@dev.mellanox.co.il>,
	<amirv@mellanox.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:43303 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752556AbaCJTGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 15:06:18 -0400
In-Reply-To: <1394474882.28217.6.camel@dcbw.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2014 20:08, Dan Williams wrote:
>
> While I could be wrong, I think the phys_port_id sysfs attribute is
> relevant here.  This attribute should be set for any VF so that
> userspace clients can determine that two VFs are backed by the same PF,
> which of course means they share bandwidth and thus some operations
> cannot be performed.  This is implemented with ndo_get_phys_port_id.
>
Indeed, and this is supported for mlx4 through the sequence of these 
commits\\

84c8640 net/mlx4_en: Implement ndo_get_phys_port_id
8e1a28e net/mlx4_core: Expose physical port id as PF/VF capability
eb17711 net/mlx4_core: Introduce nic_info new flag in QUERY_FUNC_CAP
73e74ab net/mlx4_core: Rename QUERY_FUNC_CAP fields
7b25d81 net/mlx4_core: Remove zeroed out of explicit QUERY_FUNC_CAP fields
> Dan
>
