From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [patch net-next 2/2] devlink: fix trace format string
Date: Thu, 14 Jul 2016 13:18:29 -0400
Message-ID: <20160714131829.36ae548b@gandalf.local.home>
References: <1468489049-6326-1-git-send-email-jiri@resnulli.us>
	<1468489049-6326-2-git-send-email-jiri@resnulli.us>
	<b94d448d-6009-e444-bd98-abdc848cfb00@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, arnd@arndb.de, linux-kernel@vger.kernel.org,
	idosch@mellanox.com, yotamg@mellanox.com, eladr@mellanox.com,
	nogahf@mellanox.com, ogerlitz@mellanox.com, ivecera@redhat.com,
	mingo@redhat.com, jolsa@kernel.org
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b94d448d-6009-e444-bd98-abdc848cfb00@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Jul 2016 10:07:38 -0700
Randy Dunlap <rdunlap@infradead.org> wrote:

> On 07/14/16 02:37, Jiri Pirko wrote:
> > From: Arnd Bergmann <arnd@arndb.de>
> > 
> > Including devlink.h on ARM and probably other 32-bit architectures results in
> > a harmless warning:
> > 
> > In file included from ../include/trace/define_trace.h:95:0,
> >                  from ../include/trace/events/devlink.h:51,
> >                  from ../net/core/devlink.c:30:
> > include/trace/events/devlink.h: In function 'trace_raw_output_devlink_hwmsg':
> > include/trace/events/devlink.h:42:12: error: format '%lu' expects argument of type 'long unsigned int', but argument 10 has type 'size_t {aka unsigned int}' [-Werror=format=]
> > 
> > The correct format string for 'size_t' is %zu, not %lu, this works on all
> > architectures.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Fixes: e5224f0fe2ac ("devlink: add hardware messages tracing facility")
> > Signed-off-by: Jiri Pirko <jiri@mellanox.com>  
> 
> Acked-by: Randy Dunlap <rdunlap@infradead.org>
> 

ditto!

-- Steve
