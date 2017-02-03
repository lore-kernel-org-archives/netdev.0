From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 16/19] lib: Introduce priority array area manager
Date: Fri, 3 Feb 2017 08:01:09 +0100
Message-ID: <20170203070109.GC1871@nanopsycho.orion>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
 <1486048379-19237-17-git-send-email-jiri@resnulli.us>
 <1486075870.22276.43.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, mlxsw@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, ivecera@redhat.com, jbenc@redhat.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35141 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752174AbdBCHBL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 02:01:11 -0500
Received: by mail-wm0-f66.google.com with SMTP id u63so2272646wmu.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 23:01:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1486075870.22276.43.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 02, 2017 at 11:51:10PM CET, joe@perches.com wrote:
>On Thu, 2017-02-02 at 16:12 +0100, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> This introduces a infrastructure for management of linear priority
>> areas. Priority order in an array matters, however order of items inside
>> a priority group does not matter.
>> 
>> As an initial implementation, L-sort algorithm is used. It is quite
>> trivial. More advanced algorithm called P-sort will be introduced as a
>> follow-up. The infrastructure is prepared for other algos.
>> 
>> Alongside this, a testing module is introduced as well.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  MAINTAINERS            |   8 +
>>  include/linux/parman.h |  76 ++++++++++
>[]
>> diff --git a/MAINTAINERS b/MAINTAINERS
>[]
>> @@ -9375,6 +9375,14 @@ F:	drivers/video/fbdev/sti*
>>  F:	drivers/video/console/sti*
>>  F:	drivers/video/logo/logo_parisc*
>>  
>> +PARMAN
>
>This is not particularly descriptive.
>Perhaps expand the section header a little like:
>
>PARMAN - Linear priority array areas manager

Okay


>
>> diff --git a/include/linux/parman.h b/include/linux/parman.h
>[]
>> @@ -0,0 +1,76 @@
>> +/*
>> + * include/linux/parman.h - Manager for linear priority array areas
>[]
>> diff --git a/lib/Kconfig b/lib/Kconfig
>[]
>> @@ -550,4 +550,7 @@ config STACKDEPOT
>>  config SBITMAP
>>  	bool
>>  
>> +config PARMAN
>> +	tristate "parman"
>
>help section?  Why should this be selected?

I did not put help on purpose, as for other libs. User should not never
need to select this directly because as standalone, it has no sense to
have it enabled. This is always selected by users - only mlxsw for now.


>
