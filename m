From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: linux-next: Tree for Jul 13 (net/core/devlink with Tracing)
Date: Wed, 13 Jul 2016 15:42:20 -0400
Message-ID: <20160713154220.75b3896a@gandalf.local.home>
References: <20160713164731.79532dda@canb.auug.org.au>
	<e2a29ece-79cb-6892-2e53-0b05d4ef781d@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <e2a29ece-79cb-6892-2e53-0b05d4ef781d@infradead.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Jul 2016 08:12:16 -0700
Randy Dunlap <rdunlap@infradead.org> wrote:

> On 07/12/16 23:47, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Changes since 20160712:
> >   
> 
> on x86_64:
> (full randconfig file is attached)
> 
> 
>   CC      net/core/devlink.o
> In file included from ../include/trace/define_trace.h:95:0,
>                  from ../include/trace/events/devlink.h:51,
>                  from ../net/core/devlink.c:30:
> ../include/trace/events/devlink.h: In function 'trace_event_get_offsets_devlink_hwmsg':
> ../include/trace/events/devlink.h:25:51: error: dereferencing pointer to incomplete type
>    __string(owner_name, devlink->dev->driver->owner->name)

[snip the rest]

When I remove all references to the owner_name (and that crazy
dereferencing above), it compiles fine. There must be something funky
with that devlink->dev->driver->owner->name part.

-- Steve
