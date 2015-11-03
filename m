From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next] mpls: Don't accept multipath configuration until
 the support is complete
Date: Tue, 3 Nov 2015 15:14:31 +0000
Message-ID: <5638CF57.9070203@brocade.com>
References: <1446133748-13738-1-git-send-email-roopa@cumulusnetworks.com> <87egg8ryia.fsf@x220.int.ebiederm.org> <5637BE34.10304@cogentembedded.com> <87ziyvr4w2.fsf@x220.int.ebiederm.org> <5638BE96.2010700@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:10557 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751098AbbKCPOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 10:14:49 -0500
In-Reply-To: <5638BE96.2010700@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/15 14:03, roopa wrote:
> On 11/2/15, 10:09 PM, Eric W. Biederman wrote:
>> Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:
>>
>>> Hello.
>>>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>>>> index c70d750148b6..893cd2dc3979 100644
>>>> --- a/net/mpls/af_mpls.c
>>>> +++ b/net/mpls/af_mpls.c
>>>> @@ -1162,6 +1162,8 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
>>>>    		{
>>>>    			cfg->rc_mp = nla_data(nla);
>>>>    			cfg->rc_mp_len = nla_len(nla);
>>>> +			/* Fail until multipath support is complete */
>>>> +			goto errout;
>>>>    			break;
>>>     Forgot to delete *break*?
>> Nope.  I did that deliberately, because this code is not supposed to
>> stay this way for long.
> Eric, this is only until dead route support is added correct ?.
> If yes, then my v2 on dead route/nh support is out. I know david is only taking bug fixes right now...
> and I thought the dead route/nh is a bug fix. If you are ok with v2, we could skip this patch ?.

Roopa,

I think we should take our time with the dead nexthop changes, and 
Eric's patch gives us that time.

Thanks,
Rob

>
> If david decides to not pick it up in net-next, i was hoping to submit it as a bug-fix to net.
>
