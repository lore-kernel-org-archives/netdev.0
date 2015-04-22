From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH 0/3] mpls: ABI changes for security and correctness
Date: Wed, 22 Apr 2015 11:10:38 +0100
Message-ID: <5537739E.60203@brocade.com>
References: <1429051503-31287-1-git-send-email-rshearma@brocade.com>	<1429648467-8449-1-git-send-email-rshearma@brocade.com> <87d22xm2dl.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:10686 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752613AbbDVKLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 06:11:18 -0400
In-Reply-To: <87d22xm2dl.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/04/15 01:29, Eric W. Biederman wrote:
> Robert Shearman <rshearma@brocade.com> writes:
>
>> These changes make mpls not be enabled by default on all
>> interfaces when in use for security, along with ensuring that a label
>> not valid as an outgoing label can be added in mpls routes.
>>
>> This series contains three ABI/behaviour-affecting changes which have
>> been split out from "[PATCH net-next v4 0/6] mpls: Behaviour-changing
>> improvements" without any further modification. These changes need to
>> be considered for 4.1 otherwise we'll be stuck with the current
>> behaviour/ABI forever.
>
> I don't like the difference in default between loopback and everything
> else.  That just seems like an extra arbitrary rule.

Ok, I'll get rid of that.

>
> Otherwise:
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
>
> Not that I expect Dave Miller is taking patches during the merge window.
>
>> Robert Shearman (3):
>>    mpls: Per-device MPLS state
>>    mpls: Per-device enabling of packet input
>>    mpls: Prevent use of implicit NULL label as outgoing label
>>
>>   Documentation/networking/mpls-sysctl.txt |   9 +++
>>   include/linux/netdevice.h                |   4 +
>>   net/mpls/af_mpls.c                       | 132 ++++++++++++++++++++++++++++++-
>>   net/mpls/internal.h                      |   6 ++
>>   4 files changed, 148 insertions(+), 3 deletions(-)
>
> Eric
>
