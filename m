From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: set route type for anycast routes
Date: Thu, 16 Mar 2017 21:45:12 -0600
Message-ID: <36c5c36b-a3d4-f76a-bae9-1ad2af3bea2c@cumulusnetworks.com>
References: <1489626873-5371-1-git-send-email-dsa@cumulusnetworks.com>
 <20170316.204111.427731399512369532.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:32993 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752422AbdCQDpR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 23:45:17 -0400
Received: by mail-pg0-f47.google.com with SMTP id n190so34694894pga.0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 20:45:14 -0700 (PDT)
In-Reply-To: <20170316.204111.427731399512369532.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/16/17 9:41 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Wed, 15 Mar 2017 18:14:33 -0700
> 
>> Anycast routes have the RTF_ANYCAST flag set, but when dumping routes
>> for userspace the route type is not set to RTN_ANYCAST. Make it so.
>>
>> Fixes: 58c4fb86eabcb ("[IPV6]: Flag RTF_ANYCAST for anycast routes")
>> CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> 
> Good catch, applied, thanks.

Can you put this into stable for back to say 4.4? that way tools can
directly discriminate anycast routes from host routes for at least
new'ish kernels. Thanks,
