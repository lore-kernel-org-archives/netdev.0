From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] ipv4: route: restore skb_dst_set in inet_rtm_getroute
Date: Thu, 01 Jun 2017 12:43:26 -0700
Message-ID: <59306E5E.9050806@gmail.com>
References: <1496296405-61386-1-git-send-email-roopa@cumulusnetworks.com> <20170601.113429.1492311634394467957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: David Miller <davem@davemloft.net>, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32884 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751050AbdFATni (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 15:43:38 -0400
Received: by mail-pf0-f196.google.com with SMTP id f27so8561485pfe.0
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 12:43:38 -0700 (PDT)
In-Reply-To: <20170601.113429.1492311634394467957.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2017 08:34 AM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Wed, 31 May 2017 22:53:25 -0700
> 
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> recent updates to inet_rtm_getroute dropped skb_dst_set in
>> inet_rtm_getroute. This patch restores it because it is
>> needed to release the dst correctly.
>>
>> Fixes: 3765d35ed8b9 ("net: ipv4: Convert inet_rtm_getroute to rcu versions of route lookup")
>> Reported-by: John Fastabend <john.fastabend@gmail.com>
>> Signed-off-by: David Ahern <dsahern@gmail.com>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Applied.
> 

Thanks Roopa this fixes the regression on my systems.

.John
