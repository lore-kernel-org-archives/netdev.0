From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETLINK 01/04]: Switch cb_lock spinlock to mutex and allow to
 override it
Date: Tue, 17 Apr 2007 12:40:56 +0200
Message-ID: <4624A438.3060105@trash.net>
References: <20070416074949.19262.73702.sendpatchset@localhost.localdomain>	<20070416074950.19262.97555.sendpatchset@localhost.localdomain> <20070416.165554.55726278.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62918 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413AbXDQKlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 06:41:18 -0400
In-Reply-To: <20070416.165554.55726278.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> The call signature of netlink_kernel_create() is getting huge.
> It's getting near the time we should pass in a descriotor
> block in the form of a structure to specify all of these
> parameters.


Agreed, I'll take care of that.
