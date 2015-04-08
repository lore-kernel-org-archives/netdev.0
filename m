From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH ethtool 1/5] ethtool-copy.h: sync with net
Date: Wed, 8 Apr 2015 21:40:11 +0300
Message-ID: <CAPcc5PjM5LDQC_mzpk-D7kSGFxZUJuPMmWR3f=2pcwZWCrrQrg@mail.gmail.com>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
	<1422193883-30504-2-git-send-email-amirv@mellanox.com>
	<1428195613.11260.111.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Eyal Grossman <eyalgr@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:33555 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753460AbbDHSkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 14:40:13 -0400
Received: by layy10 with SMTP id y10so72813582lay.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 11:40:11 -0700 (PDT)
In-Reply-To: <1428195613.11260.111.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 5, 2015 at 4:00 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Sun, 2015-01-25 at 15:51 +0200, Amir Vadai wrote:
>> From: Eyal Grossman <eyalgr@mellanox.com>
>>
>> This covers kernel changes up to:
>>
>> commit 892311f66f2411b813ca631009356891a0c2b0a1
>> Author: Eyal Perry <eyalpe@mellanox.com>
>> Date:   Tue Dec 2 18:12:10 2014 +0200
>>
>>       ethtool: Support for configurable RSS hash function
>>
>> Signed-off-by: Eyal Grossman <eyalgr@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>  ethtool-copy.h | 67 +++++++++++++++++++++++++++++++++++++++++++++++++++-------
>>  1 file changed, 59 insertions(+), 8 deletions(-)
>>
>> diff --git a/ethtool-copy.h b/ethtool-copy.h
>> index 61b78fc..5f66d9c 100644
>> --- a/ethtool-copy.h
>> +++ b/ethtool-copy.h
>> @@ -10,8 +10,8 @@
>>   * Portions Copyright (C) Sun Microsystems 2008
>>   */
>>
>> -#ifndef _LINUX_ETHTOOL_H
>> -#define _LINUX_ETHTOOL_H
>> +#ifndef _UAPI_LINUX_ETHTOOL_H
>> +#define _UAPI_LINUX_ETHTOOL_H
> [...]
>
> You've copied from include/uapi/linux/ethtool.h, which is not quite
> right.  The include/uapi directory contains definitions shared with
> userland, but the headers still need some processing (like removing the
> _UAPI prefix from header guards).  You should use 'make headers_install'
> to generate the userland version in usr/include/linux/ethtool.h.
> Anyway, I've done that myself based on today's net tree.
>
> Ben.

Hi,

This is a long weekend in Israel (Passover).
I will address the issues and send a V1 on Sunday.

Thanks,
Amir

>
> --
> Ben Hutchings
> Quantity is no substitute for quality, but it's the only one we've got.
