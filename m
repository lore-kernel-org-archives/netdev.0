From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 v2] bonding: correctly process non-linear skbs
Date: Tue, 14 Sep 2010 14:26:05 -0700 (PDT)
Message-ID: <20100914.142605.108789529.davem@davemloft.net>
References: <22437.1284152640@death>
	<20100910214320.GX7497@gospo.rdu.redhat.com>
	<19704.1284167315@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com, jesse.brandeburg@intel.com,
	stable@kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44793
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755548Ab0INVZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 17:25:47 -0400
In-Reply-To: <19704.1284167315@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 10 Sep 2010 18:08:35 -0700

> Andy Gospodarek <andy@greyhouse.net> wrote:
>>[PATCH net-2.6 v2] bonding: correctly process non-linear skbs
>>
>>It was recently brought to my attention that 802.3ad mode bonds would no
>>longer form when using some network hardware after a driver update.
>>After snooping around I realized that the particular hardware was using
>>page-based skbs and found that skb->data did not contain a valid LACPDU
>>as it was not stored there.  That explained the inability to form an
>>802.3ad-based bond.  For balance-alb mode bonds this was also an issue
>>as ARPs would not be properly processed.
>>
>>This patch fixes the issue in my tests and should be applied to 2.6.36
>>and as far back as anyone cares to add it to stable.
>>
>>Thanks to Alexander Duyck <alexander.h.duyck@intel.com> and Jesse
>>Brandeburg <jesse.brandeburg@intel.com> for the suggestions on this one.
>>
>>Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>>CC: Alexander Duyck <alexander.h.duyck@intel.com>
>>CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>CC: stable@kerne.org
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> 

Applied, thanks everyone.
