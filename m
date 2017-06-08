From: Marc Zyngier <marc.zyngier@arm.com>
Subject: Re: [PATCH 2/5] net: mvpp2: use {get,put}_cpu() instead of
 smp_processor_id()
Date: Thu, 8 Jun 2017 17:01:36 +0100
Message-ID: <e81a0c75-7ae2-a656-6c45-74d8694d358f@arm.com>
References: <1496935647-29670-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1496935647-29670-3-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Markus Elfring <elfring@users.sourceforge.net>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:54040 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751614AbdFHQBk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 12:01:40 -0400
In-Reply-To: <1496935647-29670-3-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/17 16:27, Thomas Petazzoni wrote:
> smp_processor_id() should not be used in migration-enabled contexts. We
> originally thought it was OK in the specific situation of this driver,
> but it was wrong, and calling smp_processor_id() in a migration-enabled
> context prints a big fat warning when CONFIG_DEBUG_PREEMPT=y.
> 
> Therefore, this commit replaces the smp_processor_id() in
> migration-enabled contexts by the appropriate get_cpu/put_cpu sections.
> 
> Reported-by: Marc Zyngier <marc.zyngier@arm.com>
> Fixes: a786841df72e ("net: mvpp2: handle register mapping and access for PPv2.2")
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Tested-by: Marc Zyngier <marc.zyngier@arm.com>

	M.
-- 
Jazz is not dead. It just smells funny...
