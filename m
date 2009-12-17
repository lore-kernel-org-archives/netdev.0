From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH]ipv6:fix an oops when force unload ipv6 module
Date: Thu, 17 Dec 2009 14:41:55 +0800
Message-ID: <4B29D2B3.80303@cn.fujitsu.com>
References: <4B29BECD.1040004@cn.fujitsu.com> <20091216215135.37d89adc@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	yoshfuji@linux-ipv6.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51931 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1762042AbZLQGjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2009 01:39:18 -0500
In-Reply-To: <20091216215135.37d89adc@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Thu, 17 Dec 2009 13:17:01 +0800
> Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
> 
>> When I do an ipv6 module force unload,I got the following oops:
>> #rmmod -f ipv6
>>
> 
> Okay, but force unloading IPV6 leaves some dangling control
> sockets that will crash in other ways.
> 

Yes,but if we make sure that there is no other services and modules
using IPV6,it can be force unloaded without causing other problems.

-- 
Regards
Yang Hongyang
