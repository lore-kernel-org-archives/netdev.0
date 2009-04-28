From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: add fifo byteswap support V2
Date: Tue, 28 Apr 2009 01:53:57 -0700 (PDT)
Message-ID: <20090428.015357.206101535.davem@davemloft.net>
References: <20090428073216.16015.15940.sendpatchset@rx1.opensource.se>
	<OFD0C1C563.A8F423C4-ON802575A6.002DDD59-802575A6.002DEC95@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: magnus.damm@gmail.com, Ian.Saturley@smsc.com, iwamatsu@nigauri.org,
	lethal@linux-sh.org, netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37594
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752922AbZD1IyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:54:04 -0400
In-Reply-To: <OFD0C1C563.A8F423C4-ON802575A6.002DDD59-802575A6.002DEC95@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve.Glendinning@smsc.com
Date: Tue, 28 Apr 2009 09:21:42 +0100

> Magnus Damm <magnus.damm@gmail.com> wrote on 28/04/2009 08:32:16:
> 
>> From: Magnus Damm <damm@igel.co.jp>
>> 
>> This is V2 of the smsc911x fifo byteswap patch.
>> 
>> The smsc911x hardware supports both big and little and endian
>> hardware configurations, and the linux smsc911x driver currently
>> detects word order.
>> 
>> For correct operation on big endian platforms lacking swapped
>> byte lanes the following patch is needed. Only fifo data is
>> swapped, register data does not require any swapping. 
>> 
>> Signed-off-by: Magnus Damm <damm@igel.co.jp>
>> ---
> 
> Acked-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.
