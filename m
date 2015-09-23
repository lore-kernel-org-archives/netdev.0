From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/9] net: Remove martian_source_keep_err goto
 label
Date: Wed, 23 Sep 2015 10:22:58 -0600
Message-ID: <5602D1E2.8020309@cumulusnetworks.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
 <1443021322-48621-2-git-send-email-dsa@cumulusnetworks.com>
 <CALx6S35EmX--C5c=4X1YZR7_botr3c1+CYMigonniDO8jCZkoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33106 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284AbbIWQXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 12:23:02 -0400
Received: by pacex6 with SMTP id ex6so44681264pac.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 09:23:02 -0700 (PDT)
In-Reply-To: <CALx6S35EmX--C5c=4X1YZR7_botr3c1+CYMigonniDO8jCZkoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/23/15 10:19 AM, Tom Herbert wrote:
>> @@ -1782,7 +1782,7 @@ out:      return err;
>>                  err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
>>                                            in_dev, &itag);
>>                  if (err < 0)
>> -                       goto martian_source_keep_err;
>> +                       goto martian_source;
>>          }
>>          flags |= RTCF_BROADCAST;
>>          res.type = RTN_BROADCAST;
>> @@ -1858,8 +1858,6 @@ out:      return err;
>>          goto out;
>>
>>   martian_source:
>> -       err = -EINVAL;
> Just remove t=above line, no need to rename label.
>

This is a stepping stone patch. It removes the unnecessary EINVAL and 
then drops one of the duplicate labels as setup for later patches. By 
patch 9 all of this is gone.
