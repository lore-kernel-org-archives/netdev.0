From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 0/6] net/mlx4: Add support to SRIOV VF management
 ndo calls
Date: Thu, 25 Apr 2013 11:11:33 +0300
Message-ID: <5178E535.10804@mellanox.com>
References: <1366821674-17902-1-git-send-email-ogerlitz@mellanox.com> <20130424.163049.2212021825718596200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:44606 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754098Ab3DYILi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 04:11:38 -0400
In-Reply-To: <20130424.163049.2212021825718596200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/04/2013 23:30, David Miller wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Wed, 24 Apr 2013 19:41:08 +0300
>
>> This series adds support for the SRIOV ndo_set_vf callbacks to the mlx4 driver.
>>
>> Series done against the net-next tree as of commit 0c501345c "batman-adv: fix
>> global protection fault during soft_iface destruction".
>>
>> We have successfully tested the series on net-next, except for getting
>> the VF link info issue I have reported earlier today on netdev, we
>> see the problem for both ixgbe and mlx4 VFs. Just to make sure get
>> VF config is working OK with patch #6 - we have run it over 3.8.8 too.
> Series applied, thanks.

Hi Dave, Looking on your patchwork archive, I see indeed that the series 
was accepted, e.g

patch 1/6 http://patchwork.ozlabs.org/patch/239279/
patch 2/6 http://patchwork.ozlabs.org/patch/239274/
patch 3/6 http://patchwork.ozlabs.org/patch/239277/
patch 4/6 http://patchwork.ozlabs.org/patch/239276/
patch 5/6 http://patchwork.ozlabs.org/patch/239278/
patch 6/6 http://patchwork.ozlabs.org/patch/239275/

but for some reason the patches don't appear on your kernel.org net-next 
tree, anything went wrong here?

Or.
