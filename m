From: <Sathya.Perla@Emulex.Com>
Subject: RE: [net-next PATCH] be2net: event queue re-design
Date: Wed, 8 Feb 2012 23:03:49 -0800
Message-ID: <3367B80B08154D42A3B2BC708B5D41F642FDEB8A5F@EXMAIL.ad.emulex.com>
References: <1328699511-2152-1-git-send-email-sathya.perla@emulex.com>
 <20120208.201230.2012432079493836273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:32393 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754422Ab2BIHEN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 02:04:13 -0500
In-Reply-To: <20120208.201230.2012432079493836273.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Thursday, February 09, 2012 6:43 AM
>
>> -#define BE_MAX_EQD		96
>> +#define BE_MAX_EQD		((u32)96)
>
>What in the world is this garbage?  You either don't need it, or you
>need to do it cleanly.  And doing it cleanly is adding a "U" postfix
>or similar to the constant, not destroying how it looks it with an
>ugly cast.

Dave, I'll fix this and re-post ...thanks.
