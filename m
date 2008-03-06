From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv8 1/2] Interface group: core and netlink part
Date: Thu, 06 Mar 2008 11:15:19 -0800 (PST)
Message-ID: <20080306.111519.46454329.davem@davemloft.net>
References: <12048121721361-git-send-email-panther@balabit.hu>
	<1204812239968-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: panther@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57720
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755352AbYCFTPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 14:15:22 -0500
In-Reply-To: <1204812239968-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laszlo Attila Toth <panther@balabit.hu>
Date: Thu,  6 Mar 2008 15:03:58 +0100

> Interface groups let handle different interfaces together.
> Modified net device structure and netlink interface.
> 
> Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>

I can't say whether this makes sense without seeing how
it will actually be used.

And both of your patches here do nothing but set and
read this group value, making it useless.

If that's all it is, userland can record such mappings
in the filesystem or elsewhere such that multiple
applications can work with and maintain the relationships.
There is zero reason to add this bloat to the kernel in
such a case.
