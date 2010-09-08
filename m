From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ethtool: Complete kernel-doc comments for
 RX flow filter and hash control
Date: Wed, 08 Sep 2010 14:05:12 -0700 (PDT)
Message-ID: <20100908.140512.242117688.davem@davemloft.net>
References: <1283870488.2270.9.camel@achroite.uk.solarflarecom.com>
	<1283870780.2270.12.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santwona.behera@sun.com, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	dm@chelsio.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42960
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754569Ab0IHVEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 17:04:55 -0400
In-Reply-To: <1283870780.2270.12.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 07 Sep 2010 15:46:20 +0100

> On Tue, 2010-09-07 at 15:41 +0100, Ben Hutchings wrote:
>> There are now several interfaces within the ethtool API for getting
>> and setting RX flow filtering and hashing behaviour, most of which are
>> poorly documented.  This adds kernel-doc comments for all these
>> interfaces, based on the existing incomplete comments and on the
>> initial implementations.
>> 
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>> ---
>> Santwona, Peter,
>> 
>> Please point out any errors and any information that should be added to
>> the comments to explain the significant differences between the RXNFC
>> and RXNTUPLE interfaces.
> [...]
>> +/**
>> + * struct ethtool_rx_ntuple - command to get or set RX flow filter
>> + * @cmd: Specific command number - %ETHTOOL_GRXNTUPLE or %ETHTOOL_SRXNTUPLE
> 
> Of course this is wrong - ETHTOOL_GRXNTUPLE uses struct ethtool_gstrings
> instead.

Ben, please submit a fixed up version of the patch.

Thanks.
