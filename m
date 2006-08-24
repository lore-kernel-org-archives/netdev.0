From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 5/44] [XFRM] STATE: Add source address list.
Date: Thu, 24 Aug 2006 10:19:47 +0900
Message-ID: <44ECFEB3.3030201@linux-ipv6.org>
References: <1156345365325-git-send-email-yoshfuji@linux-ipv6.org>	<11563453653851-git-send-email-yoshfuji@linux-ipv6.org>	<11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <20060823.175436.28791154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:2488 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S965325AbWHXBUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 21:20:34 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060823.175436.28791154.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Thu, 24 Aug 2006 00:02:06 +0900
> 
>> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
>>
>> Support source address based searching.
>> Mobile IPv6 will use it.
>> Based on MIPL2 kernel patch.
>>
>> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Patch applied to net-2.6.19, thanks a lot.
> 
> I see this is where I will need to perform conflict resolution
> with my XFRM layer hashing patches :-)

That's right.
As you may already find out the resolution will not be so hard
since this it is doing the same thing as destination hash about
XFRM list.

Thanks,

-- 
Masahide NAKAMURA
