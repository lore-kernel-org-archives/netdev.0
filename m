From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] dm9601: Fix multicast hash table handling
Date: Tue, 25 Mar 2008 23:33:45 -0400
Message-ID: <47E9C419.3040706@garzik.org>
References: <1205878614-29065-1-git-send-email-jacmet@sunsite.dk> <47E9C0E3.6040404@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44976 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755923AbYCZDdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 23:33:47 -0400
In-Reply-To: <47E9C0E3.6040404@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Peter Korsgaard wrote:
>> The loop forgot to walk the net->mc_list list, so only the first
>> multicast address was programmed into the hash table.
>>
>> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
>> ---
>>  drivers/net/usb/dm9601.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> applied three patches.
> 
> Please number your patches in the future, to indicate the order of 
> application -- even if they are roughly independent, it helps to know 
> they are in the same patch series by some method other than just the 
> References RFC-822 header


I take that back... this breaks the build:  'mlist' not defined

