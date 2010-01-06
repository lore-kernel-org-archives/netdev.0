From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 05 Jan 2010 19:57:41 -0800 (PST)
Message-ID: <20100105.195741.145481609.davem@davemloft.net>
References: <7608421F3572AB4292BB2532AE89D5658B0BAE9471@AVEXMB1.qlogic.org>
	<20100105.163343.14826539.davem@davemloft.net>
	<4B43E872.5000809@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhananjay.phadke@qlogic.com, shemminger@vyatta.com,
	amit.salecha@qlogic.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52665
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755196Ab0AFD5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 22:57:36 -0500
In-Reply-To: <4B43E872.5000809@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 05 Jan 2010 17:33:38 -0800

> David Miller wrote:
>> From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
>> Date: Tue, 5 Jan 2010 15:55:10 -0800
>> 
>>>The LRO you are talking about was still kernel based
>>>LRO. Even GRO doesn't save PCIe transactions as much
>>>HW LRO does. That is the key. The difference between
>>>HW LRO and GRO is significant to keep former alive
>>>for a while.
> 
> Is it really the PCIe transactions (*)?  ISTR that HW LRO also tended
> to significantly cut-down on the ACK rate, rather like the oft-derided
> ACK avoidance heuristics in Solaris, HP-UX and various MacOSX revs.

Yes, it causes stretch ACKs, but so does GRO.
