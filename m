From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] [PATCH v2 1/1] xen/netback: correctly calculate
 required slots of skb.
Date: Thu, 11 Jul 2013 12:04:19 -0700 (PDT)
Message-ID: <20130711.120419.1262676305594990714.davem@davemloft.net>
References: <1373447711-31303-1-git-send-email-annie.li@oracle.com>
	<20130710.191811.925426832514062553.davem@davemloft.net>
	<51DE1D1A.7020007@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, wei.liu2@citrix.com,
	Ian.Campbell@citrix.com, netdev@vger.kernel.org, msw@amazon.com
To: annie.li@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58654 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756514Ab3GKTEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 15:04:20 -0400
In-Reply-To: <51DE1D1A.7020007@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: annie li <annie.li@oracle.com>
Date: Thu, 11 Jul 2013 10:48:58 +0800

> On 2013-7-11 10:18, David Miller wrote:
>>   I prefer MAX_BUFFER_OFFSET because it gives the indication that
>> what this value represents is the modulus upon which we must chop up
>> RX buffers in this driver.
> 
> Would PAGE_SIZE be more straight? MAX_BUFFER_OFFSET gives an idea of
> offset instead of length.
> Anyway, making it consistent is a good idea.

I think the choice is a tossup, and less important than consistency.
