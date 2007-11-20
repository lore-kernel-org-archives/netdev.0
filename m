From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Tue, 20 Nov 2007 14:25:23 +0800
Message-ID: <47427DD3.9030700@cn.fujitsu.com>
References: <20071119152933.GA19126@one.firstfloor.org>	<20071119.142313.63549156.davem@davemloft.net>	<20071120002945.91fafb2b.billfink@mindspring.com> <20071119.221531.142096724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, andi@firstfloor.org,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:59094 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750894AbXKTG14 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 01:27:56 -0500
In-Reply-To: <20071119.221531.142096724.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller said the following on 2007-11-20 14:15:
> From: Bill Fink <billfink@mindspring.com>
> Date: Tue, 20 Nov 2007 00:29:45 -0500
> 
>> But the best approach seems to be just not to count
>> it in the first place until tha application has actually received
>> the packet, since as Herbert pointed out, that's what the RFC
>> actually specifies for the meaning of the udpInDatagrams counter.
> 
> I agree and would be happy to apply such a patch :)
> 
> 
> 

I want to wait for more suggestions until make such patch.
Because this solution leads to troubles with some apps, such as NFS.
(http://bugzilla.kernel.org/show_bug.cgi?id=6660#c2)

