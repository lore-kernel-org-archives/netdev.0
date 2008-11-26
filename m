From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] netns: filter out uevent not belonging to init_net
Date: Tue, 25 Nov 2008 16:46:46 -0800 (PST)
Message-ID: <20081125.164646.257454865.davem@davemloft.net>
References: <20081125165159.411202515@mai-009101017029.toulouse-stg.fr.ibm.com>
	<20081125165346.554858327@mai-009101017029.toulouse-stg.fr.ibm.com>
	<m14p1vg0us.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, netdev@vger.kernel.org,
	benjamin.thery@bull.net, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47678
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751832AbYKZAqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 19:46:47 -0500
In-Reply-To: <m14p1vg0us.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 25 Nov 2008 09:40:59 -0800

> Daniel Lezcano <dlezcano@fr.ibm.com> writes:
> 
> > This patch will filter out the uevent not related to the init_net.
> > Without this patch if a network device is created in a network
> > namespace with the same name as one network device belonging to the
> > initial network namespace (eg. eth0), when the network namespace
> > will die and the network device will be destroyed, an event will
> > be sent and catched by the udevd daemon. That will result to have
> > the real network device to be shutdown because the udevd/uevent are
> > not namespace aware.
> 
> It is belt and suspenders at this point.  As those devices should
> not even be in sysfs at the moment.  But it keeps us from doing the
> wrong thing when sysfs support starts coming on line.
> 
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied to net-next-2.6, thanks.
