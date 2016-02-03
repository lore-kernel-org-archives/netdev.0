From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bonding: 3ad: apply ad_actor settings changes
 immediately
Date: Wed, 3 Feb 2016 20:16:37 +0100
Message-ID: <56B25215.10204@cumulusnetworks.com>
References: <1454501821-22175-1-git-send-email-razor@blackwall.org>
 <7907.1454526331@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38849 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965284AbcBCTQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 14:16:40 -0500
Received: by mail-wm0-f47.google.com with SMTP id p63so85414261wmp.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 11:16:39 -0800 (PST)
In-Reply-To: <7907.1454526331@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2016 08:05 PM, Jay Vosburgh wrote:
> Nikolay Aleksandrov <razor@blackwall.org> wrote:
> 
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>> Currently the bonding allows to set ad_actor_system and prio while the
>> bond device is down, but these are actually applied only if there aren't
>> any slaves yet (applied to bond device when first slave shows up, and to
>> slaves at 3ad bind time). After this patch changes are applied immediately
>> and the new values can be used/seen after the bond's upped so it's not
>> necessary anymore to release all and enslave again to see the changes.
>>
>> CC: Jay Vosburgh <j.vosburgh@gmail.com>
>> CC: Veaceslav Falico <vfalico@gmail.com>
>> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> 	Looks good to me.
> 
> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>
> 
> 	-J
> 

Thanks Jay. Do you think it makes sense to allow setting these while the
bond is up ? I don't see any serious problems.
