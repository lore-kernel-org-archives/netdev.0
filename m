From: Justin Cormack <justin@myriabit.com>
Subject: Re: [PATCH v4] macvtap add missing ioctls - fix wrapping
Date: Wed, 13 May 2015 11:06:01 +0100
Message-ID: <1431511561.3278.6.camel@myriabit.com>
References: <1431262215.3278.2.camel@myriabit.com>
	 <20150511.134901.959375179450827063.davem@davemloft.net>
	 <1431370810.3278.4.camel@myriabit.com>
	 <20150512.230121.330638562727327262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:57567 "EHLO aibo.runbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933431AbbEMKGU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 06:06:20 -0400
In-Reply-To: <20150512.230121.330638562727327262.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-12 at 23:01 -0400, David Miller wrote:
> From: Justin Cormack <justin@myriabit.com>
> Date: Mon, 11 May 2015 20:00:10 +0100
> 
> > The macvtap driver tries to emulate all the ioctls supported by a normal
> > tun/tap driver, however it was missing the generic SIOCGIFHWADDR and
> > SIOCSIFHWADDR ioctls to get and set the mac address that are supported
> > by tun/tap. This patch adds these.
> > 
> > Signed-off-by: Justin Cormack <justin@netbsd.org>
> 
> Applied to net-next, thanks.
> 

The kbuild test picked up a stupid error, should I send a new patch
version, or a patch against net-next?

Justin
