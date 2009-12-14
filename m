From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] can: Fix data length code handling in rx path
Date: Sun, 13 Dec 2009 19:47:47 -0800 (PST)
Message-ID: <20091213.194747.115923333.davem@davemloft.net>
References: <4B23A501.9000208@hartkopp.net>
	<4B23DC72.6030307@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@hartkopp.net, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50713
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754491AbZLNDrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 22:47:45 -0500
In-Reply-To: <4B23DC72.6030307@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Sat, 12 Dec 2009 19:09:54 +0100

> Oliver Hartkopp wrote:
>> A valid CAN dataframe can have a data length code (DLC) of 0 .. 8 data bytes.
>> 
>> When reading the CAN controllers register the 4-bit value may contain values
>> from 0 .. 15 which may exceed the reserved space in the socket buffer!
>> 
>> The ISO 11898-1 Chapter 8.4.2.3 (DLC field) says that register values > 8
>> should be reduced to 8 without any error reporting or frame drop.
>> 
>> This patch introduces a new helper macro to cast a given 4-bit data length
>> code (dlc) to __u8 and ensure the DLC value to be max. 8 bytes.
>> 
>> The different handlings in the rx path of the CAN netdevice drivers are fixed.
>> 
>> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
> 
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Applied, thanks everyone.

