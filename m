From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next 1/2] devlink: fix build error for CONFIG_MODULES=n
Date: Thu, 14 Jul 2016 10:12:43 +0200
Message-ID: <4442123.LuHpPd1R94@wuerfel>
References: <20160713210338.1647521-1-arnd@arndb.de> <20160714062111.GA2228@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	"David S . Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.74]:53213 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbcGNINU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 04:13:20 -0400
In-Reply-To: <20160714062111.GA2228@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, July 14, 2016 8:21:11 AM CEST Jiri Pirko wrote:
> >diff --git a/include/trace/events/devlink.h b/include/trace/events/devlink.h
> >index 333c32ac9bfa..26f92d3c7e9c 100644
> >--- a/include/trace/events/devlink.h
> >+++ b/include/trace/events/devlink.h
> >@@ -22,7 +22,11 @@ TRACE_EVENT(devlink_hwmsg,
> >       TP_STRUCT__entry(
> >               __string(bus_name, devlink->dev->bus->name)
> >               __string(dev_name, dev_name(devlink->dev))
> >+#ifdef CONFIG_MODULES
> >               __string(owner_name, devlink->dev->driver->owner->name)
> 
> I think would be better to use driver->name. I looks like it is always
> present. I will do some tests and send a patch.
> 

Yes, good idea.

	Arnd
