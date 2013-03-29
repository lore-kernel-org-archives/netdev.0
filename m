From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sky2: Receive Overflows not counted
Date: Fri, 29 Mar 2013 14:52:52 -0400 (EDT)
Message-ID: <20130329.145252.765794718423253074.davem@davemloft.net>
References: <1902752B0C92F943AB7EA9EE13E2DEEC7F1545@HQ1-EXCH02.corp.brocade.com>
	<20130328144020.138cdc71@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mlindner@marvell.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756526Ab3C2Swx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 14:52:53 -0400
In-Reply-To: <20130328144020.138cdc71@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 28 Mar 2013 14:40:20 -0700

>> The sky2 driver doesn't count the Receive Overflows because the MAC 
>> interrupt for this event is not set in the MAC's interrupt mask.
>> The MAC's interrupt mask is set only for Transmit FIFO Underruns.
>> 
>> Fix: The correct setting should be (GM_IS_TX_FF_UR | GM_IS_RX_FF_OR)
>> Otherwise the Receive Overflow event will not generate any interrupt.
>> The  Receive Overflow interrupt is handled correctly
>> 
>> Signed-off-by: Mirko Lindner <mlindner@marvell.com>
> 
> Both these patches are fine, but the patch format seems corrupted since
> they won't directly apply with quilt.
> 
> Acked-by: Stephen Hemminger <stephen@networkplumber.org>

They apply cleanly to the 'net' tree just fine, I don't know why
it didn't work for you.
