From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] atl1: save mac address on remove
Date: Thu, 29 Mar 2007 09:45:09 -0400
Message-ID: <460BC2E5.1040504@redhat.com>
References: <20070328205151.A22317@redline.boston.redhat.com> <460BB092.5080001@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jacliburn@bellsouth.net, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36196 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753498AbXC2NpO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 09:45:14 -0400
In-Reply-To: <460BB092.5080001@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Chris Snook wrote:
>> From: Chris Snook <csnook@redhat.com>
>>
>> Some atl1 boards get their MAC address written directly to the register
>> by the BIOS during POST, rather than storing it in EEPROM that's
>> accessible to the driver.  If the MAC register on one of these boards
>> is changed and then the module is unloaded, the permanent MAC address
>> will be forgotten until the box is rebooted.  We should save the
>> permanent address during removal if we've been messing with it.
>>
>> Signed-off-by: Chris Snook <csnook@redhat.com>
> 
> applied, even though its a hack

Oh, it's definitely a hack, but the hardware it's supporting is a hack, so we 
have to work with it.

Thanks.

	-- Chris
