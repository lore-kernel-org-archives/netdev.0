From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] mpls: Don't accept multipath configuration until
 the support is complete
Date: Tue, 03 Nov 2015 06:03:02 -0800
Message-ID: <5638BE96.2010700@cumulusnetworks.com>
References: <1446133748-13738-1-git-send-email-roopa@cumulusnetworks.com> <87egg8ryia.fsf@x220.int.ebiederm.org> <5637BE34.10304@cogentembedded.com> <87ziyvr4w2.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>, rshearma@brocade.com,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35772 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754242AbbKCODH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 09:03:07 -0500
Received: by pasz6 with SMTP id z6so19574967pas.2
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 06:03:06 -0800 (PST)
In-Reply-To: <87ziyvr4w2.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/2/15, 10:09 PM, Eric W. Biederman wrote:
> Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:
>
>> Hello.
>>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>>> index c70d750148b6..893cd2dc3979 100644
>>> --- a/net/mpls/af_mpls.c
>>> +++ b/net/mpls/af_mpls.c
>>> @@ -1162,6 +1162,8 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
>>>   		{
>>>   			cfg->rc_mp = nla_data(nla);
>>>   			cfg->rc_mp_len = nla_len(nla);
>>> +			/* Fail until multipath support is complete */
>>> +			goto errout;
>>>   			break;
>>    Forgot to delete *break*?
> Nope.  I did that deliberately, because this code is not supposed to
> stay this way for long.
Eric, this is only until dead route support is added correct ?.
If yes, then my v2 on dead route/nh support is out. I know david is only taking bug fixes right now...
and I thought the dead route/nh is a bug fix. If you are ok with v2, we could skip this patch ?.

If david decides to not pick it up in net-next, i was hoping to submit it as a bug-fix to net.
