From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Module use count must be updated as bridges
 are created/destroyed
Date: Fri, 29 Apr 2011 01:10:51 -0700 (PDT)
Message-ID: <20110429.011051.183061494.davem@davemloft.net>
References: <4DBA830A020000780003ED5D@vpn.id2.novell.com>
	<20110429.002530.112581952.davem@davemloft.net>
	<4DBA87B6020000780003ED74@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	jeffm@suse.com, netdev@vger.kernel.org
To: JBeulich@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46029
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751510Ab1D2ILY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 04:11:24 -0400
In-Reply-To: <4DBA87B6020000780003ED74@vpn.id2.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@novell.com>
Date: Fri, 29 Apr 2011 08:41:10 +0100

> You talk of rmmod on the very module, but the issue is about
> modprobe -r on a dependent module. I cannot believe you consider
> it correct that *implicit* unloading of bridge.ko should happen when
> bridges are configured.

Which module in particular depends upon bridge and causes the
problem?
