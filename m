From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net-next v2 0/2] ixgbe: Add the appropriate ethtool ops
 to query RSS indirection table and key
Date: Fri, 27 Mar 2015 12:53:53 +0300
Message-ID: <551528B1.90303@cloudius-systems.com>
References: <1427409886-20261-1-git-send-email-vladz@cloudius-systems.com> <1427429878.2497.46.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37565 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbbC0Jx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 05:53:57 -0400
Received: by wiaa2 with SMTP id a2so23778565wia.0
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 02:53:55 -0700 (PDT)
In-Reply-To: <1427429878.2497.46.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/27/15 07:17, Jeff Kirsher wrote:
> On Fri, 2015-03-27 at 00:44 +0200, Vlad Zolotarov wrote:
>> Add the ethtool ops to VF driver to allow querying the RSS indirection
>> table
>> and RSS Random Key.
>>
>> This series refactors the RSS configuration code to store the current
>> contents of
>> RSS indirection table and Hash Key in the "adapter" struct so that we
>> won't need
>> to access registers every time this info is queried.
>>
>> New in v2:
>>     - Some styling fixes.
>>     - Moved macros definitions from ixgbe_type.h to ixgbe.h.
>>
>> Vlad Zolotarov (2):
>>    ixgbe: Refactor the RSS configuration code.
>>    ixgbe: Add the appropriate ethtool ops to query RSS indirection
>> table
>>      and key
> I am assuming that this series is to replace the latest v8 series,
> correct?

This series is a precondition for v9. I have prepared it and waited for 
this series to get it... I'll send it on Sunday.

Have a nice weekend...
