From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gre_offload: simplify GRE header length
 calculation in gre_gso_segment()
Date: Mon, 13 Jan 2014 11:54:08 -0800 (PST)
Message-ID: <20140113.115408.687861949295975907.davem@davemloft.net>
References: <1389318437-17744-1-git-send-email-ncardwell@google.com>
	<1389319758.31367.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, edumazet@google.com,
	hkchu@google.com, pshelar@nicira.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38248 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458AbaAMTyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:54:09 -0500
In-Reply-To: <1389319758.31367.81.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Jan 2014 18:09:18 -0800

> On Thu, 2014-01-09 at 20:47 -0500, Neal Cardwell wrote:
>> Simplify the GRE header length calculation in gre_gso_segment().
>> Switch to an approach that is simpler, faster, and more general. The
>> new approach will continue to be correct even if we add support for
>> the optional variable-length routing info that may be present in a GRE
>> header.
>> 
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: H.K. Jerry Chu <hkchu@google.com>
>> Cc: Pravin B Shelar <pshelar@nicira.com>
>> ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thank you.
