From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 06/10] {NET,IB}/mlx4: Add device managed flow
 steering firmware API
Date: Tue, 3 Jul 2012 14:10:29 +0300
Message-ID: <4FF2D325.40604@mellanox.com>
References: <20120702.013445.1273332212099485403.davem@davemloft.net> <1341252445.2590.12.camel@bwh-desktop.uk.solarflarecom.com> <20120702.171507.1288066003825644221.davem@davemloft.net> <20120702.180458.2296165153479998120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <bhutchings@solarflare.com>, <roland@kernel.org>,
	<yevgenyp@mellanox.com>, <oren@mellanox.com>,
	<netdev@vger.kernel.org>, <hadarh@mellanox.co.il>,
	"Amir Vadai" <amirv@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:32821 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932450Ab2GCLKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 07:10:37 -0400
In-Reply-To: <20120702.180458.2296165153479998120.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/3/2012 4:04 AM, David Miller wrote:
>
> Just in case you guys _really_ and _truly_ are so unable to think
> outside the box that you can't come up with something reasonable, I'll
> get you started with two ideas:
>
> 1) A special "chipset" dummy netdev that a special class of ethtool
>     commands can run on to set these things.
>
> 2) A "chipset" genetlink family with suitable operations and
>     attributes.

Dave,

Thanks for trying to address the need here, as I wrote you, we've 
removed the module param
from the patch-set and will submit V1 without this. Once the comments 
are over and hopefully
the patches are accepted, we'll see what can/need to be done for 
allowing that flexibility.

Or.

>
>
> In both cases appropriate mechanisms are added to make for keys that
> are used for chipset matching, and device drivers simply register
> a notifier handler that is called on two occaisions:
>
> 1) When settings are changed.
>
> 2) Upon initial handler registry, to acquire the initial settings.
