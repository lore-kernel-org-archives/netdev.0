From: Daniel Hellstrom <daniel@gaisler.com>
Subject: Re: [PATCH 02/10] GRETH: added option to disable a device node from
 bootloader.
Date: Fri, 14 Jan 2011 08:45:48 +0100
Message-ID: <4D2FFF2C.3050904@gaisler.com>
References: <1294907135-24884-1-git-send-email-daniel@gaisler.com>	<1294907135-24884-2-git-send-email-daniel@gaisler.com> <20110113.221238.97339127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail202c2.megamailservers.com ([69.49.111.103]:55467 "EHLO
	mail202c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753943Ab1ANHp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 02:45:59 -0500
In-Reply-To: <20110113.221238.97339127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

>From: Daniel Hellstrom <daniel@gaisler.com>
>Date: Thu, 13 Jan 2011 09:25:27 +0100
>
>  
>
>>Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
>>    
>>
>
>This is not how you do this.
>
>Simply not present the device in the OpenFirmware tree at all.  If you
>can make this special properly appear, you can also toss the device
>node away completely.
>
>There is zero reason whatsoever to create a special hack-job
>non-standardized device node properly to do this.
>  
>
I agree, I will remove it. The optional parameter should be a setting 
for a particular device rather that a "disable device" parameter.

Thanks,
Daniel

