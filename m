From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sh_eth: fix incorrect RX length error if
 R8A7740
Date: Wed, 12 Jun 2013 12:55:52 -0700 (PDT)
Message-ID: <20130612.125552.1263337397196293337.davem@davemloft.net>
References: <51B7CFFB.7090801@renesas.com>
	<51B88271.1030101@cogentembedded.com>
	<51B8C84A.7000708@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshihiro.shimoda.uh@renesas.com, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754947Ab3FLT4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 15:56:05 -0400
In-Reply-To: <51B8C84A.7000708@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 12 Jun 2013 23:13:14 +0400

> Hello.
> 
> On 06/12/2013 06:15 PM, Sergei Shtylyov wrote:
> 
>>> This patch fixes an issue that the driver increments the "RX length
>>> error"
>>> on every buffer in sh_eth_rx() if the R8A7740.
>>> This patch also adds a description about the Receive Frame Status
>>> bits.
> 
>>      Thank you.
> 
>>> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
>>> ---
>>>   This patch is based on the latest net-next.git.
> 
>>     Since this is a fix, it should have been done against 'net.git'.
> 
>    David, this patch applies to the recent net.git repo with offset.
> Could you merge it there and also queue for stable?

Repost it so that I can apply it cleanly.
