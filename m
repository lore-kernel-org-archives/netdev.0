From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net-next v1 0/5]: ixgbevf: Allow querying VFs RSS indirection
 table and key
Date: Wed, 31 Dec 2014 18:20:26 +0200
Message-ID: <54A4224A.9060103@cloudius-systems.com>
References: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com> <1420041700.31582.36.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gleb@cloudius-systems.com,
	avi@cloudius-systems.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:49742 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbaLaQUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 11:20:30 -0500
Received: by mail-wi0-f172.google.com with SMTP id n3so25720444wiv.17
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 08:20:29 -0800 (PST)
In-Reply-To: <1420041700.31582.36.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/31/14 18:01, Jeff Kirsher wrote:
> On Wed, 2014-12-31 at 11:51 +0200, Vlad Zolotarov wrote:
>> Add the ethtool ops to VF driver to allow querying the RSS indirection
>> table
>> and RSS Random Key.
>>   
>>   - PF driver: Add new VF-PF channel commands.
>>   - VF driver: Utilize these new commands and add the corresponding
>>                ethtool callbacks.
>>
>> New in v1 (compared to RFC):
>>     - Use "if-else" statement instead of a "switch-case" for a single
>> option case.
>>       More specifically: in cases where the newly added API version is
>> the only one
>>       allowed. We may consider using a "switch-case" back again when
>> the list of
>>       allowed API versions in these specific places grows up.
> Thanks Vlad, I will add your series to my queue.

Great! Thanks a lot Jeff!

Happy New Year to everybody!
