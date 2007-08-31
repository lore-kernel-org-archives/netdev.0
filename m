From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 2/3]S2io: Support for add/delete/store/restore
 ethernet addresses
Date: Fri, 31 Aug 2007 14:38:56 -0400
Message-ID: <46D86040.5030105@garzik.org>
References: <Pine.GSO.4.10.10708220206510.22078-100000@guinness>	<46D81777.2090700@garzik.org> <20070831.113604.29572801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sreenivasa.Honnur@neterion.com, netdev@vger.kernel.org,
	support@neterion.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48321 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965887AbXHaSjC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 14:39:02 -0400
In-Reply-To: <20070831.113604.29572801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Fri, 31 Aug 2007 09:28:23 -0400
> 
>> Sreenivasa Honnur wrote:
>>> - Support to add/delete/store/restore 64 and 128 Ethernet addresses for
>>> Xframe I and Xframe II respectively.
>>>
>>> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
>>> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
>> What is the purpose of this?  We do not support more than one unicast 
>> MAC address at present...
> 
> Yes we do, the card can register with the card in ->set_rx_mode() or
> enable promiscuous mode if it has no alternate MAC facility.
> 
> See netdev->uc_list.

Ah, well objection removed then.  I stand corrected.  Didn't know it was 
in yet.

	Jeff



