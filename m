From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: Add schedule check to napi_enable call
Date: Thu, 10 Feb 2011 11:01:19 -0800 (PST)
Message-ID: <20110210.110119.226784284.davem@davemloft.net>
References: <201102101232.50526.rusty@rustcorp.com.au>
	<20110210175725.GA9674@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kstailey@yahoo.com
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51973
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754833Ab1BJTAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 14:00:43 -0500
In-Reply-To: <20110210175725.GA9674@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 10 Feb 2011 19:57:26 +0200

> On Thu, Feb 10, 2011 at 12:32:50PM +1030, Rusty Russell wrote:
>> From: "Bruce Rogers" <brogers@novell.com>
>> 
>> Under harsh testing conditions, including low memory, the guest would
>> stop receiving packets. With this patch applied we no longer see any
>> problems in the driver while performing these tests for extended periods
>> of time.
>> 
>> Make sure napi is scheduled subsequent to each napi_enable.
>> 
>> Signed-off-by: Bruce Rogers <brogers@novell.com>
>> Signed-off-by: Olaf Kirch <okir@suse.de>
>> Cc: stable@kernel.org
>> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> Rusty, so this is 2.6.38 material - you'll send this to Linus? Or DaveM?

Don't worry I'll apply this to net-2.6, thanks.
