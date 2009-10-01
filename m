From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: set primary param via sysfs
Date: Thu, 01 Oct 2009 14:39:41 -0700 (PDT)
Message-ID: <20091001.143941.105761293.davem@davemloft.net>
References: <20090918121321.GB2801@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39626
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751906AbZJAVjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 17:39:22 -0400
In-Reply-To: <20090918121321.GB2801@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 18 Sep 2009 14:13:22 +0200

> Primary module parameter passed to bonding is pernament. That means if you
> release the primary slave and enslave it again, it becomes the primary slave
> again. But if you set primary slave via sysfs, the primary slave is only set
> once and it's not remembered in bond->params structure. Therefore the setting is
> lost after releasing the primary slave. This simple one-liner fixes this.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks Jiri.
