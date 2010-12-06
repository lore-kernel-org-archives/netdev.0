From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2] ehea: Use the standard logging functions
Date: Mon, 06 Dec 2010 13:02:28 -0800 (PST)
Message-ID: <20101206.130228.70206311.davem@davemloft.net>
References: <4CF52E7C.7010308@linux.vnet.ibm.com>
	<1291141124.18026.254.camel@Joe-Laptop>
	<4CF7EB82.5020609@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57679
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752583Ab0LFVCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 16:02:00 -0500
In-Reply-To: <4CF7EB82.5020609@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Breno Leitao <leitao@linux.vnet.ibm.com>
Date: Thu, 02 Dec 2010 16:54:58 -0200

> On 11/30/2010 04:18 PM, Joe Perches wrote:
>> Remove ehea_error, ehea_info and ehea_debug macros.
>> Use pr_fmt, pr_<level>, netdev_<level> and netif_<level> as
>> appropriate.
>> Fix messages to use trailing "\n", some messages had an extra one
>> as the old ehea_<level>  macros added a trailing "\n".
>> Coalesced long format strings.
>>
>> Uncompiled/untested.
>>
>> Signed-off-by: Joe Perches<joe@perches.com>
> Signed-off-by: Breno Leitao<leitao@linux.vnet.ibm.com>

Applied.
