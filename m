From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH -next] gianfar, ucc_geth: Use proper address
	translation for MDIO buses
Date: Thu, 19 Mar 2009 21:19:48 +0300
Message-ID: <20090319181948.GA9360@oksana.dev.rtsoft.ru>
References: <20090318192152.GA29621@oksana.dev.rtsoft.ru> <A41D3E28-93C8-46FD-A87A-EDE6C4D4E77B@kernel.crashing.org>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Scott Wood <scottwood@freescale.com>,
	Andy Fleming <afleming@freescale.com>,
	Li Yang <leoli@freescale.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	linuxppc-dev@ozlabs.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.79.90.228] ([213.79.90.228]:39259 "EHLO
	buildserver.ru.mvista.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754760AbZCSSTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 14:19:51 -0400
Content-Disposition: inline
In-Reply-To: <A41D3E28-93C8-46FD-A87A-EDE6C4D4E77B@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2009 at 03:57:10AM -0500, Kumar Gala wrote:
> On Mar 18, 2009, at 2:21 PM, Anton Vorontsov wrote:
[...]
>> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
>> ---
>>
>> This is for 2.6.30 since we don't use ranges = <> yet.
>>
>> David, I believe Kumar would like to pick this patch into his tree
>> along with a patch set that adds "ranges = <>" properties to the
>> device tree... So would you mind if we take it via powerpc.git?
>>
>> Thanks,
>>
>> drivers/net/gianfar_mii.c  |   10 +++++++---
>> drivers/net/ucc_geth_mii.c |   10 +++++++---
>> 2 files changed, 14 insertions(+), 6 deletions(-)
>
> Andy merged these in net-next to just have drivers/net/fsl_pq_mdio.c.
>
> My suggestion is to update the patch against -next and have David put it 
> into net-next.
>
> (I'll deal w/the .dts updates in powerpc.git and cherry pick commits out 
> of net-next into my testing branching)

Btw, if we want some testing for .dts changes, you could just merge
this patch into your powerpc.git tree along with other patches, and
then, when merge window opens, just fix a trivial conflict in
{ucc_geth,gianfar}_mii.c files (i.e. just remove the files).

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
