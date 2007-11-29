From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Thu, 29 Nov 2007 18:33:01 +0800
Message-ID: <474E955D.7010108@cn.fujitsu.com>
References: <20071119.142313.63549156.davem@davemloft.net> <20071120002945.91fafb2b.billfink@mindspring.com> <20071120140518.GA1502@one.firstfloor.org> <20071120.173928.53148729.davem@davemloft.net> <474E707A.3080106@cn.fujitsu.com> <20071129092136.GB30066@gondor.apana.org.au> <474E8F9E.7040309@cn.fujitsu.com> <20071129102122.GA22537@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, gerrit@erg.abdn.ac.uk,
	bfields@fieldses.org, neilb@suse.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:53298 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751324AbXK2Kff (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 05:35:35 -0500
In-Reply-To: <20071129102122.GA22537@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu said the following on 2007-11-29 18:21:
> On Thu, Nov 29, 2007 at 06:08:30PM +0800, Wang Chen wrote:
>> Add a new UdpInEarlyDatagrams counter to count datagrams received early,
>> but which might be dropped later.
> 
> Could you please split this into two patches? Have one do the
> UdpInDatagrams change and the other to introduce the EarlyDatagrams
> counter.
> 
> I'm a bit hesitant to introduce new counters in the MIB because
> it'd be difficult if not impossible to ever remove them.  Do you
> really need the early counter?
> 

I cooked the patch based on Andi's and left the new counter.
Frankly, I don't like the EarlyDatagrams too.
So, I will remove it and resubmit.

> One more thing, please put the is_udplite clean-up in its own
> patch too so it's absolutely clear what we're changing in the
> patches that aren't clean-ups.
> 

OK.

>> Signed-off-by: Andi Kleen <ak@suse.de>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> Who's the author? Andi or you? Please make this obvious with a From
> header when you resubmit.
> 

Since I will remove the new counter idea of Andi, there will be only
one author. :)

