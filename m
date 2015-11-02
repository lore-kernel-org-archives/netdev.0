From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC] mpls: support for dead routes
Date: Mon, 02 Nov 2015 13:18:27 -0800
Message-ID: <5637D323.7090602@cumulusnetworks.com>
References: <1446133748-13738-1-git-send-email-roopa@cumulusnetworks.com> <87twp5tnq3.fsf@x220.int.ebiederm.org> <5636B5D1.9070901@cumulusnetworks.com> <87d1vtt2di.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rshearma@brocade.com, davem@davemloft.net, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33068 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256AbbKBVS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 16:18:28 -0500
Received: by pabfh17 with SMTP id fh17so35313091pab.0
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 13:18:28 -0800 (PST)
In-Reply-To: <87d1vtt2di.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/1/15, 9:08 PM, Eric W. Biederman wrote:
> roopa <roopa@cumulusnetworks.com> writes:
>
>> On 11/1/15, 1:27 PM, Eric W. Biederman wrote:
>>> Roopa Prabhu <roopa@cumulusnetworks.com> writes:
>>>
>>>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>>>> index c70d750..7db9678 100644
>>>> --- a/net/mpls/af_mpls.c
>>>> +++ b/net/mpls/af_mpls.c
>>>> @@ -27,6 +27,8 @@
>>>>   */
>>>>  #define MAX_MP_SELECT_LABELS 4
>>>>  
>>>> +u32 mpls_multipath_secret __read_mostly;
>>> This mpls_multipath_secret is never used.
>>>
>> It is used in mpls_multipath_rebalance, same as fib_rebalance.
> fib_multipath_secret is only initialized in fib_rebalalance.
> fib_multipath_secret is used used in fib_multipath_hash,
> which is called in fib_select_path.
>
> The equivalent code does not exist in your mpls patch.
sorry, missed that. I have posted a new version.
