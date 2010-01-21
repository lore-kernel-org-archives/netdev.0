From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost: fix TUN=m VHOST_NET=y
Date: Thu, 21 Jan 2010 01:28:56 -0800 (PST)
Message-ID: <20100121.012856.244222536.davem@davemloft.net>
References: <20100120113037.GA9182@redhat.com>
	<20100120084910.a869aca8.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, rusty@rustcorp.com.au, netdev@vger.kernel.org,
	sfr@canb.auug.org.au
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56247
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752742Ab0AUJ2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 04:28:47 -0500
In-Reply-To: <20100120084910.a869aca8.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 20 Jan 2010 08:49:10 -0800

> On Wed, 20 Jan 2010 13:30:38 +0200 Michael S. Tsirkin wrote:
> 
>> drivers/built-in.o: In function `get_tun_socket':
>>     net.c:(.text+0x15436e): undefined reference to `tun_get_socket'
>> 
>> If tun is a module, vhost must be a module, too.
>> If tun is built-in or disabled, vhost can be built-in.
>> 
>> Note: TUN || !TUN might look a bit strange until you realize
>> that boolean logic rules do not apply for tristate variables.
>> 
>> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied to net-next-2.6, thanks!
