From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/11] sky2: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 15:56:16 -0800 (PST)
Message-ID: <20100120.155616.144451404.davem@davemloft.net>
References: <20100120232102.GD3072@del.dom.local>
	<20100120.153451.62650459.davem@davemloft.net>
	<20100120235245.GE3072@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48902
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753325Ab0ATX4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:56:06 -0500
In-Reply-To: <20100120235245.GE3072@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 21 Jan 2010 00:52:45 +0100

> On Wed, Jan 20, 2010 at 03:34:51PM -0800, David Miller wrote:
>> Whereas 1 patch in the 1 place in the DMA API implementation would fix
>> everything for everybody.
> 
> 1) As I mentioned earlier there were similar dmar errors reported with
> real oopses, but of course it might be unconnected. (But why risk...)

Show me the DMAR code that handles DMA SYNC requests.

There isn't any.

So it's impossible for this to fix things for DMAR users.

