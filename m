From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [ethtool PATCH] ethtool: Can't parse ints with stroul()
Date: Wed, 23 Dec 2009 16:52:39 -0500
Message-ID: <4B329127.8020002@garzik.org>
References: <20091208173240.19917.99052.stgit@localhost.localdomain> <9929d2390912091712g6d0543e9y170f21712b9efb7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:59780 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755651AbZLWVwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 16:52:42 -0500
Received: by ywh12 with SMTP id 12so8280740ywh.21
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2009 13:52:41 -0800 (PST)
In-Reply-To: <9929d2390912091712g6d0543e9y170f21712b9efb7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/2009 08:12 PM, Jeff Kirsher wrote:
> On Tue, Dec 8, 2009 at 09:32, Jeff Kirsher<jeffrey.t.kirsher@intel.com>  wrote:
>> From: PJ Waskiewicz<peter.p.waskiewicz.jr@intel.com>
>>
>> A recent change to how int's were being parsed from the command
>> line had them being read in with an unsigned int string operator.
>> This didn't allow signed numbers from being read in correctly.
>> This patch adds a get_uint() routine, and fixes the get_int()
>> routine to read in signed values.
>>
>> Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>> ---
>>
>
> Jeff G. - hold off on this patch.  We have a version 2 in the works,
> because we found if the sign bit was set on a uint, this would fail
> parsing.

Was version 2 ever posted?  I never saw it...

	Jeff



