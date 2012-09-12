From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [V3 PATCH 9/9] cxgb4vf: Chelsio FCoE offload driver submission
 (header compatibility fixes).
Date: Wed, 12 Sep 2012 11:57:06 +0530
Message-ID: <50502B3A.6080803@chelsio.com>
References: <1347374347-3852-10-git-send-email-naresh@chelsio.com> <20120911.133321.282568248903907762.davem@davemloft.net> <50501F1A.6040905@chelsio.com> <20120912.014746.636228439025755624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6238 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876Ab2ILG1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 02:27:22 -0400
In-Reply-To: <20120912.014746.636228439025755624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/12/2012 11:17 AM, David Miller wrote:
> From: Naresh Kumar Inna <naresh@chelsio.com>
> Date: Wed, 12 Sep 2012 11:05:22 +0530
> 
>> On 9/11/2012 11:03 PM, David Miller wrote:
>>> From: Naresh Kumar Inna <naresh@chelsio.com>
>>> Date: Tue, 11 Sep 2012 20:09:07 +0530
>>>
>>>> This patch contains minor fixes to make cxgb4vf driver work with the updates to
>>>> shared firmware/hardware header files.
>>>>
>>>> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
>>>
>>> You cannot submit a patch set that isn't bisectable, and in particular
>>> create a situation that mid-way through your patch set things do not
>>> build or operate correctly.
>>>
>>
>> Sorry, I am new to this process. The reason I did that was because I was
>> not sure if I could create a single patch with both cxgb4 and cxgb4vf
>> files in it, since they are two different subsystems. If I could do
>> that, the single patch then would build on its own, and not be dependent
>> on the other patches in the series. Is that something I can do?
> 
> I don't know how else to say this, every step along the way the tree
> has to build.  You arrange the patches however necessary to achieve
> that goal.
> 

OK, I think I should be able to arrange the patch set to fulfill that
requirement. I was under the impression it was fine for new drivers to
split patches in this fashion, since they go as a single commit, sorry
about that.

As for a single patch with both cxgb4 and cxgb4vf changes, I assume it
is OK for the commit log to start with "cxgb4/cxgb4vf:..."?

Thanks,
Naresh.
