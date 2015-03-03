From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH v3] bridge: fix bridge netlink RCU usage
Date: Tue, 03 Mar 2015 06:57:12 -0800
Message-ID: <54F5CBC8.2000303@cumulusnetworks.com>
References: <1425390556-17844-1-git-send-email-johannes@sipsolutions.net>  <54F5C5C1.9000306@cumulusnetworks.com>  (sfid-20150303_153134_259974_794D3171) <1425394292.2450.47.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:37624 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756644AbbCCO5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 09:57:14 -0500
Received: by paceu11 with SMTP id eu11so10735906pac.4
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 06:57:13 -0800 (PST)
In-Reply-To: <1425394292.2450.47.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/3/15, 6:51 AM, Johannes Berg wrote:
> Hi Roopa,
>
>> My subsequent patch  in net-next related to this code, changes things a
>> bit (fed0a159c8c5e453d79d6a73897c576efea0a8a5 bridge: fix link
>> notification skb size calculation to include vlan ranges).
> Yeah, I saw this, but thought the original patch had already gone to
> net.git. Then later I found it hasn't but didn't remember ... sorry
> about that.
>
>> It reverts the use of this function which makes sure this is always
>> called under rtnl.
>> But, I did add another version of this function in net-next which has
>> the same problem.
>> Assuming that patch in net-next is on its way to net soon, am wondering
>> if fixing it in net-next is the right course.
> Of course, this patch should then only ever be applied to net-next.
>
>> I can apply your patch there and re-submit. Or if you prefer to
>> re-submit your patch on net-next that's great too.
> I can resend it. I even have a pretty simple test case to reproduce the
> failure :)
>
great!. Thank you.
