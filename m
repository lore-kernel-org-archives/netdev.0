From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rtnetlink: remove unused ifla_stats_policy
Date: Thu, 08 Sep 2016 19:56:47 -0700
Message-ID: <57D224EF.10009@cumulusnetworks.com>
References: <20160907135736.7a986302@xeon-e3> <20160908.172319.506563196312084552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34947 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbcIIC4u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 22:56:50 -0400
Received: by mail-pf0-f182.google.com with SMTP id w87so24383970pfk.2
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 19:56:49 -0700 (PDT)
In-Reply-To: <20160908.172319.506563196312084552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/8/16, 5:23 PM, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Wed, 7 Sep 2016 13:57:36 -0700
>
>> This structure is defined but never used. Flagged with W=1
>>
>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> This comes from commit 10c9ead9f3c6bb24bddc9a96681f7d58e6623966
> ("rtnetlink: add new RTM_GETSTATS message to dump link stats")
>
> Roopa, did you intentionally put this here unreferenced for the
> purposes or documentation or something like that?

I went back and looked at all my submissions to remember why i had it.
I don't seem to have used it anywhere...but i had expressed an intent to use
it to parse filter attributes in incoming stats requests in my first few versions.

I possibly just forgot to drop it after i moved to a mask to filter incoming stats requests.
thanks for checking...

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

and thanks stephen for cleaning this up.
