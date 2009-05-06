From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [PATCH] net: update skb_recycle_check() for hardware
 timestamping changes
Date: Wed, 06 May 2009 15:11:39 +0200
Message-ID: <1241615499.26936.25.camel@pohly-MOBL>
References: <20090506111311.GD24429@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4425 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756529AbZEFNLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 09:11:42 -0400
In-Reply-To: <20090506111311.GD24429@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-05-06 at 14:13 +0300, Lennert Buytenhek wrote:
> Commit ac45f602ee3d1b6f326f68bc0c2591ceebf05ba4 ("net: infrastructure
> for hardware time stamping") added two skb initialization actions to
> __alloc_skb(), which need to be added to skb_recycle_check() as well.

Good catch, thanks. For what it's worth:

Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.


