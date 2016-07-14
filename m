From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] devlink: fix build error for
 CONFIG_MODULES=n
Date: Thu, 14 Jul 2016 10:51:38 +0200
Message-ID: <20160714085138.GD2228@nanopsycho.orion>
References: <20160713210338.1647521-1-arnd@arndb.de>
 <20160714062111.GA2228@nanopsycho.orion>
 <4442123.LuHpPd1R94@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	"David S . Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4442123.LuHpPd1R94@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Jul 14, 2016 at 10:12:43AM CEST, arnd@arndb.de wrote:
>On Thursday, July 14, 2016 8:21:11 AM CEST Jiri Pirko wrote:
>> >diff --git a/include/trace/events/devlink.h b/include/trace/events/devlink.h
>> >index 333c32ac9bfa..26f92d3c7e9c 100644
>> >--- a/include/trace/events/devlink.h
>> >+++ b/include/trace/events/devlink.h
>> >@@ -22,7 +22,11 @@ TRACE_EVENT(devlink_hwmsg,
>> >       TP_STRUCT__entry(
>> >               __string(bus_name, devlink->dev->bus->name)
>> >               __string(dev_name, dev_name(devlink->dev))
>> >+#ifdef CONFIG_MODULES
>> >               __string(owner_name, devlink->dev->driver->owner->name)
>> 
>> I think would be better to use driver->name. I looks like it is always
>> present. I will do some tests and send a patch.
>> 
>
>Yes, good idea.


I will take your second path, rebase and send along. Thanks.

>
>	Arnd
>
