From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] mpls: Don't accept multipath configuration until the support is complete
Date: Tue, 03 Nov 2015 00:09:01 -0600
Message-ID: <87ziyvr4w2.fsf@x220.int.ebiederm.org>
References: <1446133748-13738-1-git-send-email-roopa@cumulusnetworks.com>
	<87egg8ryia.fsf@x220.int.ebiederm.org>
	<5637BE34.10304@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, rshearma@brocade.com,
	netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:34192 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729AbbKCGR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 01:17:26 -0500
In-Reply-To: <5637BE34.10304@cogentembedded.com> (Sergei Shtylyov's message of
	"Mon, 2 Nov 2015 22:49:08 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:

> Hello.
>>
>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>> index c70d750148b6..893cd2dc3979 100644
>> --- a/net/mpls/af_mpls.c
>> +++ b/net/mpls/af_mpls.c
>> @@ -1162,6 +1162,8 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
>>   		{
>>   			cfg->rc_mp = nla_data(nla);
>>   			cfg->rc_mp_len = nla_len(nla);
>> +			/* Fail until multipath support is complete */
>> +			goto errout;
>>   			break;
>
>    Forgot to delete *break*?

Nope.  I did that deliberately, because this code is not supposed to
stay this way for long.

Eric
