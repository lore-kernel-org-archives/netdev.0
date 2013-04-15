From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 1/2] net: add dev_uc_sync_multiple() and dev_mc_sync_multiple()
 api
Date: Mon, 15 Apr 2013 15:37:47 -0400
Message-ID: <516C570B.2000901@redhat.com>
References: <1366052997-12435-1-git-send-email-vyasevic@redhat.com> <1366052997-12435-2-git-send-email-vyasevic@redhat.com> <20130415.153628.1799560140670027402.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752989Ab3DOThv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 15:37:51 -0400
In-Reply-To: <20130415.153628.1799560140670027402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2013 03:36 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Mon, 15 Apr 2013 15:09:56 -0400
>
>> The current implementation of dev_uc_sync/unsync() assumes that there is
>> a strict 1-to-1 relationship between the source and destination of the case.
>> This is not always the case.  Some virtual devices aggreated a number
>> of lower devices and need to sync the address to all of them.  The current
>> API falls short there.
>>
>> This patch introduces a new dev_uc_sync_multiple() api that can be called
>> in the above circumstances and allows sync to work for every invocation.
>>
>> CC: Jiri Pirko <jiri@resnulli.us>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>
> Did patch #2 get killed by a cosmic ray?  :-)
>
> I didn't see it get posted yet.
>

I got a CC copy.  I'll let float for a few more minutes.  If it doesn't 
arrive, I'll resend it.

-vlad
