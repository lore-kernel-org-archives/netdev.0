From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: iproute2 mpls max labels
Date: Sat, 23 Jul 2016 16:04:40 -0700
Message-ID: <5793F808.6090309@cumulusnetworks.com>
References: <578A7BF0.2020107@nordu.net> <57911A26.3080203@cumulusnetworks.com> <579125CB.3030201@nordu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert Shearman <rshearma@brocade.com>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>
To: Magnus Bergroth <bergroth@nordu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34620 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbcGWXEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2016 19:04:43 -0400
Received: by mail-pa0-f47.google.com with SMTP id fi15so49820819pac.1
        for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 16:04:43 -0700 (PDT)
In-Reply-To: <579125CB.3030201@nordu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/21/16, 12:43 PM, Magnus Bergroth wrote:
>
>> Roopa Prabhu <mailto:roopa@cumulusnetworks.com>
>> 21 juli 2016 20:53
>> I did not realize it is hardcoded to 8 in iproute2. Because kernel has
>> a hard coded limit of
>> 2.
>> I think we need to fix it in a few places:
>> a) we should move the kernel #define to a uapi header file which
>> iproute2 can use
>> b) there has been a general ask to bump the kernel MAX_LABELS from 2
>> and I don't see
>> a problem with it yet. so, we could bump it to 8.
>>
>> Were you planning to post patches for one or both of the above ?.
>>
>> I can post them too. Let me know.
> I would be happy if you could post them both as I very new to the kernel
> development and I'm not entirely sure how to do it in the right way.
>
ok, sure, will fix it.

thanks,
Roopa
