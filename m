From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net] net/mlx4: Cache line CQE/EQE stride fixes
Date: Tue, 16 Dec 2014 14:29:11 +0200
Message-ID: <54902597.50105@mellanox.com>
References: <1418729334-2974-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"clsoto@linux.vnet.ibm.com" <clsoto@linux.vnet.ibm.com>,
	Ido Shamay <idos@mellanox.com>,
	Wei Yang <weiyang@linux.vnet.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0059.outbound.protection.outlook.com ([157.56.112.59]:20944
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750881AbaLPM3r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 07:29:47 -0500
In-Reply-To: <1418729334-2974-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2014 1:28 PM, Amir Vadai wrote:
> From: Ido Shamay <idos@mellanox.com>
> 
> This commit contains 2 fixes for the 128B CQE/EQE stride feaure.
> Wei found that mlx4_QUERY_HCA function marked the wrong capability
> in flags (64B CQE/EQE), when CQE/EQE stride feature was enabled.
> Also added small fix in initial CQE ownership bit assignment, when CQE
> is size is not default 32B.
> 
> Fixes: 77507aa24 (net/mlx4: Enable CQE/EQE stride support)
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> Signed-off-by: Ido Shamay <idos@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
> Dave Hi,
> 
> Please pull this patch also to stable (at least 3.17)
> 
> Thanks,
> Amir

Small correction: Should pull into -stable >= 3.18

Amir
