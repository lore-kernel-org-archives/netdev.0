From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC] mpls: support for dead routes
Date: Sun, 01 Nov 2015 17:01:05 -0800
Message-ID: <5636B5D1.9070901@cumulusnetworks.com>
References: <1446133748-13738-1-git-send-email-roopa@cumulusnetworks.com> <87twp5tnq3.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rshearma@brocade.com, davem@davemloft.net, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33184 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbbKBBBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 20:01:07 -0500
Received: by pabfh17 with SMTP id fh17so6001035pab.0
        for <netdev@vger.kernel.org>; Sun, 01 Nov 2015 17:01:07 -0800 (PST)
In-Reply-To: <87twp5tnq3.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/1/15, 1:27 PM, Eric W. Biederman wrote:
> Roopa Prabhu <roopa@cumulusnetworks.com> writes:
>
>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>> index c70d750..7db9678 100644
>> --- a/net/mpls/af_mpls.c
>> +++ b/net/mpls/af_mpls.c
>> @@ -27,6 +27,8 @@
>>   */
>>  #define MAX_MP_SELECT_LABELS 4
>>  
>> +u32 mpls_multipath_secret __read_mostly;
> This mpls_multipath_secret is never used.
>
It is used in mpls_multipath_rebalance, same as fib_rebalance.
