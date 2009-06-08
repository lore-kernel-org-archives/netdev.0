From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netdev: smsc911x: allow building on Blackfin
 systems
Date: Mon, 08 Jun 2009 14:37:10 -0700 (PDT)
Message-ID: <20090608.143710.83724675.davem@davemloft.net>
References: <1244248640-22699-1-git-send-email-vapier@gentoo.org>
	<OF063E0F2B.DD999013-ON802575CF.006B45BD-802575CF.006BB3F8@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vapier@gentoo.org, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org, Ian.Saturley@smsc.com
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53568
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751320AbZFHVhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 17:37:08 -0400
In-Reply-To: <OF063E0F2B.DD999013-ON802575CF.006B45BD-802575CF.006BB3F8@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve.Glendinning@smsc.com
Date: Mon, 8 Jun 2009 20:36:24 +0100

> You're right, there's nothing "special" about ARM | SUPERH other than they 
> cover all the in-tree platforms using smsc911x.  The aim was to hide this 
> option from menuconfig on x86 etc, where this device is extremely unlikely 
> to be found.  Maybe there's a better way of doing this?

I sincerely doubt keeping this out of x86's menuconfig so important,
really.

So many devices are available for powerpc and sparc64 that will never
appear there, however those drivers now get build validated on those
platforms and it's therefore a net-win.
