From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: Fix handling packets on compound pages
 with skb_segment
Date: Tue, 05 Aug 2014 16:45:00 -0700 (PDT)
Message-ID: <20140805.164500.1875405528479445448.davem@davemloft.net>
References: <20140803091110.GA7093@zion.uk.xensource.com>
	<20140804.152411.1486639478907964423.davem@davemloft.net>
	<53E0D56E.7020205@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, konrad.wilk@oracle.com,
	boris.ostrovsky@oracle.com, david.vrabel@citrix.com,
	Ian.Campbell@citrix.com, paul.durrant@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53E0D56E.7020205@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Tue, 5 Aug 2014 14:00:30 +0100

> On 04/08/14 23:24, David Miller wrote:
>> Given what I've seen so far, I think the only option is to linearize
>> the packet.
> I think that would have more performance penalty than calling
> skb_gso_segment, but maybe I'm wrong.

We have firmly established that you cannot legally use GSO segmenting
as an option, so it doesn't matter if it's faster or not.
