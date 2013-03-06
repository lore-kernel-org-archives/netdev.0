From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] benet: Wait f/w POST until timeout
Date: Tue, 05 Mar 2013 23:58:36 -0500 (EST)
Message-ID: <20130305.235836.1815836004691126948.davem@davemloft.net>
References: <1362383327-32362-1-git-send-email-shangw@linux.vnet.ibm.com>
	<20130305.163431.2055740152739079020.davem@davemloft.net>
	<dd3bebd7-d92d-4485-b4a6-413df763b985@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shangw@linux.vnet.ibm.com, netdev@vger.kernel.org,
	subbu.seetharaman@emulex.com, Ajit.Khaparde@Emulex.Com
To: Sathya.Perla@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509Ab3CFE6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 23:58:37 -0500
In-Reply-To: <dd3bebd7-d92d-4485-b4a6-413df763b985@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Date: Wed, 6 Mar 2013 04:45:03 +0000

>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
>> 
>> From: Gavin Shan <shangw@linux.vnet.ibm.com>
>> Date: Mon,  4 Mar 2013 15:48:46 +0800
>> 
>> > While PCI card faces EEH errors, reset (usually hot reset) is expected
>> > to recover from the EEH errors. After EEH core finishes the reset, the
>> > driver callback (be_eeh_reset) is called and wait the firmware to
>> > complete POST successfully. The original code would return with error
>> > once detecting failure during POST stage. That seems not enough.
>> >
>> > The patch forces the driver (be_eeh_reset) to wait the firmware
>> > completes POST until timeout, instead of returning error upon
>> > detection POST failure immediately. Also, it would improve the
>> > reliability of the EEH funtionality of the driver.
>> >
>> > Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>> 
>> I know that patch #2 of this series needs to be implemented differently, but this
>> patch seems fine.
>> 
>> So can I get an ACK from one of the benet driver folks?
> 
> Acked-by: Sathya Perla <sathya.perla@emulex.com>

Applied, thanks for reviewing.
