From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] tun: fix aio
Date: Tue, 21 Apr 2009 06:02:46 -0700 (PDT)
Message-ID: <20090421.060246.150234623.davem@davemloft.net>
References: <20090420112527.GA6692@dhcp-1-124.tlv.redhat.com>
	<20090421125020.GA9740@dhcp-1-124.tlv.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, rusty@rustcorp.com.au
To: m.s.tsirkin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37746
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751272AbZDUNCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 09:02:55 -0400
In-Reply-To: <20090421125020.GA9740@dhcp-1-124.tlv.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>
Date: Tue, 21 Apr 2009 15:50:21 +0300

> On Mon, Apr 20, 2009 at 02:25:27PM +0300, Michael S. Tsirkin wrote:
>> The following patches make tun_chr_aio_read and tun_chr_aio_write not modify
>> the iovec so that io_submit/io_getevents succeed, becoming functionally
>> equivalent to write/read on the device.
> 
> What are the thoughts on these patches?
> Is this a reasonable thing to do?

Man, you're real impatient.

I just applied your patches to net-next-2.6 and was going to let you
know that I had done this.

Sit tight next time, if you changes are under review they'll be
happily sitting right here:

http://patchwork.ozlabs.org/project/netdev/list/

where you can monitor their status until they're either applied
or rejected.

:-P
