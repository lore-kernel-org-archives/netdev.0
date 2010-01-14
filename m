From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC][PATCH] IP: Send a fragment reassembly time exceeded packet
 when enabling connection track
Date: Thu, 14 Jan 2010 17:18:52 +0800
Message-ID: <4B4EE17C.60708@cn.fujitsu.com>
References: <4B3191E7.8060509@cn.fujitsu.com> <4B42D1C3.3020207@trash.net> <4B4D3AD3.6050403@cn.fujitsu.com> <4B4D83FD.5040604@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B4D83FD.5040604@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote, at 01/13/2010 04:27 PM:
>> Should end hosts which are using conntrack send a fragment reassembly time exceeded message?
> 
> Yes, they should.

OK. Please ignore the patch, because the patch is wrong.
With the patch, a router also send a fragment reassembly time exceeded message
when reassembling timeout.

I'll make a new patch to fix the problem. After testing, then submit it. 

-- 
Best Regards
-----
Shan Wei

