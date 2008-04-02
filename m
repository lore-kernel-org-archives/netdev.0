From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][VLAN]: Proc entry is not renamed when vlan device name
 changes.
Date: Wed, 02 Apr 2008 00:08:19 -0700 (PDT)
Message-ID: <20080402.000819.76892095.davem@davemloft.net>
References: <47F0E1C7.7040908@openvz.org>
	<47F1DBD8.9080603@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41864
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756596AbYDBHIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 03:08:19 -0400
In-Reply-To: <47F1DBD8.9080603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 01 Apr 2008 08:53:12 +0200

> Pavel Emelyanov wrote:
> > This may lead to situations, when each of two proc entries produce
> > data for the other's device.
> > 
> > Looks like a BUG, so this patch is for net-2.6. It will not apply 
> > to net-2.6.26 since dev->nd_net access is replaced with dev_net(dev) 
> > one. Should I rework the patch to fit 2.6.26?
> 
> No, since its a bugfix it should go in net-2.6. Dave, please apply.

Done.
