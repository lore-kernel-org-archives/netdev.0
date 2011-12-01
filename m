From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: only use primary address for ARP
Date: Wed, 30 Nov 2011 23:00:15 -0500 (EST)
Message-ID: <20111130.230015.1895271350696416498.davem@davemloft.net>
References: <20111124093715.GA25365@as68121.uab.ericsson.se>
	<20111130220709.GI25132@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: henrik.e.persson@ericsson.com, netdev@vger.kernel.org,
	fubar@us.ibm.com
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660Ab1LAEA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:00:29 -0500
In-Reply-To: <20111130220709.GI25132@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Wed, 30 Nov 2011 17:07:10 -0500

> On Thu, Nov 24, 2011 at 10:37:15AM +0100, Henrik Saavedra Persson wrote:
>> Only use the primary address of the bond device
>> for master_ip. This will prevent changing the ARP source
>> address in Active-Backup mode whenever a secondry address
>> is added to the bond device.
>> 
>> Signed-off-by: Henrik Saavedra Persson <henrik.e.persson@ericsson.com>
 ...
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

Applied, thanks for reviewing Andy.
