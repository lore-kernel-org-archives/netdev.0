From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next RFC] mpls: support for dead routes
Date: Sun, 01 Nov 2015 23:08:09 -0600
Message-ID: <87d1vtt2di.fsf@x220.int.ebiederm.org>
References: <1446133748-13738-1-git-send-email-roopa@cumulusnetworks.com>
	<87twp5tnq3.fsf@x220.int.ebiederm.org>
	<5636B5D1.9070901@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: rshearma@brocade.com, davem@davemloft.net, netdev@vger.kernel.org
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59835 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbbKBFQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 00:16:31 -0500
In-Reply-To: <5636B5D1.9070901@cumulusnetworks.com>
	(roopa@cumulusnetworks.com's message of "Sun, 01 Nov 2015 17:01:05
	-0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

roopa <roopa@cumulusnetworks.com> writes:

> On 11/1/15, 1:27 PM, Eric W. Biederman wrote:
>> Roopa Prabhu <roopa@cumulusnetworks.com> writes:
>>
>>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>>> index c70d750..7db9678 100644
>>> --- a/net/mpls/af_mpls.c
>>> +++ b/net/mpls/af_mpls.c
>>> @@ -27,6 +27,8 @@
>>>   */
>>>  #define MAX_MP_SELECT_LABELS 4
>>>  
>>> +u32 mpls_multipath_secret __read_mostly;
>> This mpls_multipath_secret is never used.
>>
> It is used in mpls_multipath_rebalance, same as fib_rebalance.

fib_multipath_secret is only initialized in fib_rebalalance.
fib_multipath_secret is used used in fib_multipath_hash,
which is called in fib_select_path.

The equivalent code does not exist in your mpls patch.

Eric
