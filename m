From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Offloading bonds to hardware
Date: Fri, 13 Nov 2015 14:10:06 -0500 (EST)
Message-ID: <20151113.141006.1048458234203733687.davem@davemloft.net>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
	<56462E38.5090600@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pjonnala@broadcom.com, netdev@vger.kernel.org, sfeldma@gmail.com,
	jiri@resnulli.us, nikolay@cumulusnetworks.com, idosch@mellanox.com,
	gospo@cumulusnetworks.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbbKMTKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 14:10:10 -0500
In-Reply-To: <56462E38.5090600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 13 Nov 2015 10:38:48 -0800

> This is a good explanation of why you want the changes, and how this is
> implemented in a system utilizing that, but this is not documenting why
> you are making these changes to the bonding code, nor how they are
> supposed to be used by an implementor driver, since there is no such
> user posted (yet?).

I am basically not even going to look at proposals for new device ops
that don't also show an actual user of the new interfaces.

That's not how we do development, and not providing a real example
user of a new set of interfaces makes it impossible to properly review
such changes.
