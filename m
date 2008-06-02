From: Bill Gatliff <bgat@billgatliff.com>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Mon, 02 Jun 2008 11:09:58 -0500
Message-ID: <48441B56.8080905@billgatliff.com>
References: <1211200476-21297-1-git-send-email-steve.glendinning@smsc.com> <1212403502-4604-1-git-send-email-steve.glendinning@smsc.com> <20080602155415.GA6192@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org, Michael.Hennerich@analog.com,
	Enrik.Berkhan@ge.com, hennerich@blackfin.uclinux.org,
	ian.saturley@smsc.com, uclinux-dist-devel@blackfin.uclinux.org,
	catalin.marinas@arm.com, Bahadir Balban <Bahadir.Balban@arm.com>,
	Dustin Mcintire <dustin@sensoria.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from venus.billgatliff.com ([209.251.101.201]:49939 "EHLO
	venus.billgatliff.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbYFBQiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 12:38:55 -0400
In-Reply-To: <20080602155415.GA6192@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
>> +static int smsc911x_phy_loopbacktest(struct smsc911x_data *pdata)
>> +{
>> +	int result = 0;
>> +	unsigned int i;
>> +	unsigned int val;
>> +	unsigned long flags;
>> +
>> +	/* Initialise tx packet using broadcast destination address */
>> +	for (i = 0; i < 6; i++)
>> +		pdata->loopback_tx_pkt[i] = (char)0xFF;
> 
> The cast to char is just noise.

Not sure.  What about signed vs. unsigned?


b.g.
-- 
Bill Gatliff
bgat@billgatliff.com
