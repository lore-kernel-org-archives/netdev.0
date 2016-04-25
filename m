From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: Delete host routes on an ifdown
Date: Mon, 25 Apr 2016 15:30:34 -0700
Message-ID: <571E9A8A.50808@cumulusnetworks.com>
References: <1461297372-18796-1-git-send-email-dsa@cumulusnetworks.com> <20160425.152611.583503438886577374.davem@davemloft.net> <571E72AA.4030100@cumulusnetworks.com> <20160425.164227.1599148827995063295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org,
	mmanning@brocade.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34798 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbcDYWag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 18:30:36 -0400
Received: by mail-pa0-f48.google.com with SMTP id r5so63794111pag.1
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 15:30:36 -0700 (PDT)
In-Reply-To: <20160425.164227.1599148827995063295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/25/16, 1:42 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Mon, 25 Apr 2016 13:40:26 -0600
>
>> It's unfortunate you want to take that action. Last week I came across
>> a prior attempt by Stephen to do this same thing -- keep IPv6
>> addresses. That prior attempt was reverted by commit
>> 73a8bd74e261. Cumulus, Brocade, and others clearly want this
>> capability.
> But nobody has implemented it correctly, it doesn't matter who wants
> the feature.  That's why it keeps getting reverted.
>
> Also, this testing you are talking about should have happened long
> before you submitted that first patch that introduced all of these
> regressions.  My observations tell me that the bulk of the testing
> happened afterwards and that's why all the regressions are popping up
> now.
sorry if it seems that way. But we have been testing several versions of this patch
internally. davidA has been throwing it at all of our internal tests just to make sure
it gets all the testing it needs before 4.6 goes out. This last fix was something
that I think got introduced in one of the later versions during re-implementing
bits of it based on feedback. And one of our new recent tests under stress
caught it and we rushed the fix out.

thanks,
Roopa
