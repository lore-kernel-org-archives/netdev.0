From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/2] devlink: fix trace format string
Date: Thu, 14 Jul 2016 22:16:24 -0700 (PDT)
Message-ID: <20160714.221624.1127895350526666434.davem@davemloft.net>
References: <1468489049-6326-1-git-send-email-jiri@resnulli.us>
	<1468489049-6326-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de, rdunlap@infradead.org,
	linux-kernel@vger.kernel.org, idosch@mellanox.com,
	yotamg@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com, ivecera@redhat.com, rostedt@goodmis.org,
	mingo@redhat.com, jolsa@kernel.org
To: jiri@resnulli.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468489049-6326-2-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 14 Jul 2016 11:37:29 +0200

> From: Arnd Bergmann <arnd@arndb.de>
> 
> Including devlink.h on ARM and probably other 32-bit architectures results in
> a harmless warning:
> 
> In file included from ../include/trace/define_trace.h:95:0,
>                  from ../include/trace/events/devlink.h:51,
>                  from ../net/core/devlink.c:30:
> include/trace/events/devlink.h: In function 'trace_raw_output_devlink_hwmsg':
> include/trace/events/devlink.h:42:12: error: format '%lu' expects argument of type 'long unsigned int', but argument 10 has type 'size_t {aka unsigned int}' [-Werror=format=]
> 
> The correct format string for 'size_t' is %zu, not %lu, this works on all
> architectures.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: e5224f0fe2ac ("devlink: add hardware messages tracing facility")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
