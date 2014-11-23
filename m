From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vlan: Pass ethtool get_ts_info queries to
 real device.
Date: Sun, 23 Nov 2014 13:48:09 -0500 (EST)
Message-ID: <20141123.134809.1311687203339230014.davem@davemloft.net>
References: <1416575780-19132-1-git-send-email-richardcochran@gmail.com>
	<1416712512.7215.34.camel@decadent.org.uk>
	<20141123160533.GA4562@netboy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	stefan.sorensen@spectralink.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbaKWSsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 13:48:11 -0500
In-Reply-To: <20141123160533.GA4562@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sun, 23 Nov 2014 17:05:35 +0100

> On Sun, Nov 23, 2014 at 03:15:12AM +0000, Ben Hutchings wrote:
>> This assumes that the same PTP capabilities apply to VLAN-tagged frames.
>> I don't think it's at all safe to assume that RX filter modes other than
>> HWTSTAMP_FILTER_ALL will include VLAN-tagged frames.  I think it is
>> necessary to define additional modes that explicitly include VLAN-tagged
>> frames.
> 
> Unsafe? How?
> 
> Do you mean that some HW cannot identify and time stamp PTP frames
> when VLAN tagged? That is surely disappointing for people who shell
> out money for such cards, but it is hardly unsafe.

Ben, you will have to provide a concrete example of a chip that will
do the wrong thing with Richard's change.

Hypotheticals won't cut it.

Thanks.
