From: David Miller <davem@davemloft.net>
Subject: Re: e1000e oops
Date: Fri, 05 Oct 2007 13:53:37 -0700 (PDT)
Message-ID: <20071005.135337.74737230.davem@davemloft.net>
References: <20071005131115.GA31453@stro.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: max@stro.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39368
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760724AbXJEUxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 16:53:38 -0400
In-Reply-To: <20071005131115.GA31453@stro.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: maximilian attems <max@stro.at>
Date: Fri, 5 Oct 2007 15:11:15 +0200

> net eth1: device_rename: sysfs_create_symlink failed (-17)
 ...
> no idea if aboves belongs to netdev or sysfs dep.

I think the report belongs to udev.

It tries to rename network devices even if they already
have the name it desires.
