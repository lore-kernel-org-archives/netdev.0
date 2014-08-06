From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 0/3] Make is_kdump_kernel() accessible from modules
Date: Wed, 6 Aug 2014 11:10:18 +0300
Message-ID: <53E1E2EA.6020102@mellanox.com>
References: <20140730123513.GB14804@redhat.com>	<53D9E789.4070607@mellanox.com>	<20140731130756.GE11063@redhat.com> <20140731.122244.665794236590108427.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <amirv@mellanox.com>, <andi@firstfloor.org>,
	<akpm@linux-foundation.org>, <netdev@vger.kernel.org>,
	<ogerlitz@mellanox.com>, <yevgenyp@mellanox.com>
To: David Miller <davem@davemloft.net>, <vgoyal@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:45753 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753262AbaHFIKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 04:10:40 -0400
In-Reply-To: <20140731.122244.665794236590108427.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/31/2014 10:22 PM, David Miller wrote:
> From: Vivek Goyal <vgoyal@redhat.com>
> Date: Thu, 31 Jul 2014 09:07:56 -0400
> 
>> If there are performance implications of low memory profile, then user
>> needs to live with it. Otherwise they should not use low_memory_env
>> boot option to begin with.
> 
> I personally think we should avoid changing scripts, by having a kdump
> kernel force this low_mem profile to be true.
Hi,

Is there work needed to be done on those patches? It seems that the
approach taken by those patches is accepted at the end. Also, Vivek
Goyal has acked it.

This patch is fixing stuff [1] that got into last 'net-next' (3.17).
Should I wait for it to appear in the next 'net' and send the patchset
to 'net' or can I send it now to 'net-next'?

[1] ea1c1af ("net/mlx4_en: Reduce memory consumption on kdump kernel")
    and
    2599d85 ("net/mlx4_core: Use low memory profile on kdump kernel")

Thanks,
Amir

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
