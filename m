From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: sctp: get rid of SCTP_DBG_TSNS entirely
Date: Mon, 01 Jul 2013 18:33:57 +0200
Message-ID: <51D1AF75.50907@redhat.com>
References: <1372671096-27129-1-git-send-email-dborkman@redhat.com> <20130701113342.GA3168@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21501 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252Ab3GAQeH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 12:34:07 -0400
In-Reply-To: <20130701113342.GA3168@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2013 01:33 PM, Neil Horman wrote:
> On Mon, Jul 01, 2013 at 11:31:36AM +0200, Daniel Borkmann wrote:
>> After having reworked the debugging framework, Neil and Vlad agreed to
>> get rid of the leftover SCTP_DBG_TSNS code for a couple of reasons:
>>
>> We can use systemtap scripts to investigate these things, we now have
>> pr_debug() helpers that make life easier, and if we really need anything
>> else besides those tools, we will be forced to come up with something
>> better than we have there. Therefore, get rid of this ifdef debugging
>> code entirely for now.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> CC: Vlad Yasevich <vyasevich@gmail.com>
>> CC: Neil Horman <nhorman@tuxdriver.com>
>> ---
>>   On top of [PATCH net-next v4 0/2] Rework SCTP debugging framework.
>>
> I think you mean on top of v4 2/2, but regardless:
>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
>
> I don't suppose you want to write a stap script to drop in the sourceware
> examples area, in case anyone comes looking for this functionality again? :)

I could put this into my longer-term todo queue, sure, sounds like a plan.

> Thanks
> Neil
