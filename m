From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH]IPv6:remove duplicate check of optlen when setsockopt
 with IPV6_PKTINFO option
Date: Thu, 15 Jan 2009 18:07:49 +0800
Message-ID: <496F0AF5.5060804@cn.fujitsu.com>
References: <20090114.210242.163189105.davem@davemloft.net>	<496ECACB.5090300@cn.fujitsu.com>	<20090115053702.GA30403@gondor.apana.org.au> <20090114.214521.132298096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62937 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752936AbZAOKHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 05:07:42 -0500
In-Reply-To: <20090114.214521.132298096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 15 Jan 2009 16:37:02 +1100
> 
>> On Thu, Jan 15, 2009 at 01:34:03PM +0800, Yang Hongyang wrote:
>>> Dave,there are some of the code elsewhere return EFAULT when
>>> optval=NULL,I will post a patch to fix them:)
>> I disagree.  The concept of a user-space NULL pointer is different
>> to that of a kernel-space NULL pointer, so the kernel should not
>> be treating a user-space NULL pointer differently than any other
>> pointer.
> 
> I agree with Herbert, but of course we have to adhere to cases
> where APIs actually define a user NULL pointer to have a specific
> meaning.
> 
> 

Agreed.Seems that Patch v2 is correct according to the discussion.^_^

-- 
Regards
Yang Hongyang
