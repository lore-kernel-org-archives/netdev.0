From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net-next v1 4/5] ixgbevf: Add RSS Key query code
Date: Wed, 31 Dec 2014 20:36:55 +0200
Message-ID: <54A44247.7030703@cloudius-systems.com>
References: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com>		 <1420019519-18139-5-git-send-email-vladz@cloudius-systems.com>	 <1420043307.31582.53.camel@jtkirshe-mobl>	 <54A43A67.9020407@cloudius-systems.com> <1420050773.31582.71.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gleb@cloudius-systems.com,
	avi@cloudius-systems.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:44262 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbaLaSg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 13:36:59 -0500
Received: by mail-we0-f178.google.com with SMTP id p10so2736115wes.9
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 10:36:57 -0800 (PST)
In-Reply-To: <1420050773.31582.71.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/31/14 20:32, Jeff Kirsher wrote:
> On Wed, 2014-12-31 at 20:03 +0200, Vlad Zolotarov wrote:
>> On 12/31/14 18:28, Jeff Kirsher wrote:
>>> On Wed, 2014-12-31 at 11:51 +0200, Vlad Zolotarov wrote:
>>>> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
>>>> ---
>>>> New in v1 (compared to RFC):
>>>>      - Use "if-else" statement instead of a "switch-case" for a
>> single
>>>> option case
>>>>        (in ixgbevf_get_rss_key()).
>>>>
>>>> ---
>>>>    drivers/net/ethernet/intel/ixgbevf/mbx.h |  2 ++
>>>>    drivers/net/ethernet/intel/ixgbevf/vf.c  | 44
>>>> ++++++++++++++++++++++++++++++++
>>>>    drivers/net/ethernet/intel/ixgbevf/vf.h  |  1 +
>>>>    3 files changed, 47 insertions(+)
>>> Just caught this now, sorry but your patch description is sparse
>> (i.e.
>>> non-existent).  I know that the title of the patch pretty much tells
>>> what you are doing, but it would be nice to have a bit more detail
>> as to
>>> why (like your first patch).
>> I've sent a v2 where I tried to address your last remarks. Pls., note
>> that the whole series "why" motivation is located in the PATCH0 and
>> in
>> the final PATCH5: adding a new ethtool options for 82599 VF devices.
> Thanks v2 appears fine with regards to code/patch format goes.  Alex
> Duyck appears to have provided feedback on the series, which is a
> concern for me.  I have dropped v1 (since v2 is out), but I am going to
> hold off on pulling in v2 until Alex's concerns have been addressed.

Sure. He's caught a few real issues there. The main is that I had only 
82599 in mind and there are also x540 and x550 to consider. It may take 
a day or two... ;)
Again, thanks for looking at this guys.
