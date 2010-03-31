From: Stuart Shelton <stuart@openobjects.com>
Subject: Re: Severe regression in bnx2 driver with bonding in post 2.6.30 kernels
Date: Wed, 31 Mar 2010 19:04:34 +0100
Message-ID: <6B2CE77E-B4DD-484F-A69A-6752A4E698DE@openobjects.com>
References: <C27F8246C663564A84BB7AB3439772421AF2CD5940@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 157.187.34.193.bridgep.com ([193.34.187.157]:7181 "EHLO
	smtp.openobjects.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752890Ab0CaSEg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 14:04:36 -0400
In-Reply-To: <C27F8246C663564A84BB7AB3439772421AF2CD5940@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Michael,

Thanks for the reply.  When I first became aware of this problem, I checked ibm.com and applied the most recent Bladecenter/LS21 firmware updates - so the NIC firmware should be current compared to what IBM officially offers.

The ethtool output is:

$ sudo ethtool -i eg0
driver: bnx2
version: 2.0.1
firmware-version: 4.6.1 ipms 1.6.0
bus-info: 0000:02:04.0

The latest IBM firmware update appears to be:

http://www-947.ibm.com/systems/support/supportsite.wss/docdisplay?lndocid=MIGR-5083668&brandind=5000020

Many thanks,

Stuart


On 31 Mar 2010, at 17:01, Michael Chan wrote:

> Stuart Shelton wrote:
> 
>> The Broadcom NetXtreme II driver appears to have a severe
>> regression in
>> all kernels post 2.6.30 - I've observed problems with 2.6.31, 2.6.32.
>> and 2.6.33.
>> 
>> The hardware impacted is an IBM Bladecenter LS21 Blade, model
>> 7971.  We
>> have a large number of these, and all are affected.
>> 
> 
> Can you provide me ethtool -i eth0 to see what the NVRAM-based
> firmware version is?  Thanks.
> 

