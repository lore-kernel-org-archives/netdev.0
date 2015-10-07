From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Fix vti use case with oif in dst lookups
 for IPv6
Date: Wed, 7 Oct 2015 08:12:16 -0600
Message-ID: <56152840.6040701@cumulusnetworks.com>
References: <1444055571-82546-1-git-send-email-dsa@cumulusnetworks.com>
 <20151007.042525.1310561159530454910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33167 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbbJGOMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 10:12:15 -0400
Received: by pacex6 with SMTP id ex6so22851248pac.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 07:12:14 -0700 (PDT)
In-Reply-To: <20151007.042525.1310561159530454910.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/7/15 5:25 AM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Mon,  5 Oct 2015 08:32:51 -0600
>
>> It occurred to me yesterday that 741a11d9e4103 ("net: ipv6: Add
>> RT6_LOOKUP_F_IFACE flag if oif is set") means that xfrm6_dst_lookup
>> needs the FLOWI_FLAG_SKIP_NH_OIF flag set. This latest commit causes
>> the oif to be considered in lookups which is known to break vti. This
>> explains why 58189ca7b274 did not the IPv6 change at the time it was
>> submitted.
>>
>> Fixes: 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>
> If this is needed in v4.3 why are you targetting net-next?

default git setting. Missed removal before send.

>
> I applied it to both trees...
>

thank you.
