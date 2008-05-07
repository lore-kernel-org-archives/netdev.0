From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] NET: Remove PACKET_FASTROUTE
Date: Wed, 07 May 2008 17:45:50 +0800
Message-ID: <48217A4E.7060200@cn.fujitsu.com>
References: <4821713E.7050308@cn.fujitsu.com> <20080507.023524.193709565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51811 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752057AbYEGJrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2008 05:47:55 -0400
In-Reply-To: <20080507.023524.193709565.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-5-7 17:35:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Wed, 07 May 2008 17:07:10 +0800
> 
>> Since we do not support fastroute anymore, remove macro PACKET_FASTROUTE.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> We should leave it there so that this value is not accidently
> allocatod to another purpose.
> 
> If you really really want to remove it, at least add a comment
> there that value "6" used to be allocated to PACKET_FASTROUTE,
> and therefore cannot be reused.
> 
> But, to be honest, keeping the define there serves that purpose just
> as well.
> 

Yes. I agree. So leave it there.

