From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-2.6] Re-enable IP when MTU > 68
Date: Fri, 29 Aug 2008 13:33:45 -0700 (PDT)
Message-ID: <20080829.133345.248034879.davem@davemloft.net>
References: <48B80D6B.5030007@linux.vnet.ibm.com>
	<20080829150506.GO7908@solarflare.com>
	<48B81457.9010105@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	rafaello@br.ibm.com
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58760
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753391AbYH2Udu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 16:33:50 -0400
In-Reply-To: <48B81457.9010105@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Breno Leitao <leitao@linux.vnet.ibm.com>
Date: Fri, 29 Aug 2008 12:23:03 -0300

> Ben, 
> 
> Ben Hutchings wrote:
> > Should be >= to match the other tests.  And it would really be cleaner to
> > use something like
> > 
> > 	static inline bool inetdev_valid_mtu(unsigned mtu)
> > 	{
> > 		return mtu >= 68;
> > 	}
> Where is the best place to insert this function ?

Right above the two places it would be called :)
