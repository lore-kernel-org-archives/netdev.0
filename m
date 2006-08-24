From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 18/44] [IPV6]: Add Kconfig to enable Mobile IPv6.
Date: Thu, 24 Aug 2006 11:55:36 +0900
Message-ID: <44ED1528.9000605@linux-ipv6.org>
References: <11563453661892-git-send-email-yoshfuji@linux-ipv6.org>	<11563453661207-git-send-email-yoshfuji@linux-ipv6.org>	<11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <20060823.191437.02297536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	takamiya@po.ntts.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:980 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1030222AbWHXCzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 22:55:15 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060823.191437.02297536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Thu, 24 Aug 2006 00:02:19 +0900
> 
>> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
>>
>> Add Kconfig to enable Mobile IPv6.
>> Based on MIPL2 kernel patch.
>>
>> Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
>> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Applied to net-2.6.19
> 
> Won't we also need a selection of route optimization and/or subtree
> options when enabling the mobile ipv6 config option?

We won't need them for building. I thought this option should be
just for the basic MIPv6 feature (i.e. knowledge of header types)
then I didn't add such dependency.

However, if we would think this option is a switch for enabling
MIPv6 roles (i.e. CN, HA and MN),

RO mode: Yes, it is required by all roles.

Policy routing: I guess No. Because it is not required by CN.
(required by MN, used by HA only for supporting physical home link)

Regards,

-- 
Masahide NAKAMURA
