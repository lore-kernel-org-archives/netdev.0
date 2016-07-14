From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [patch net-next 1/2] tracing: change owner name to driver name
 for devlink hwmsg tracepoint
Date: Thu, 14 Jul 2016 13:11:03 -0400
Message-ID: <20160714131103.5d02f0e9@gandalf.local.home>
References: <1468489049-6326-1-git-send-email-jiri@resnulli.us>
	<89c61610-47f0-bfab-0642-7152f90936e8@infradead.org>
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
In-Reply-To: <89c61610-47f0-bfab-0642-7152f90936e8@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Jul 2016 10:07:33 -0700
Randy Dunlap <rdunlap@infradead.org> wrote:

> On 07/14/16 02:37, Jiri Pirko wrote:
> > From: Jiri Pirko <jiri@mellanox.com>
> > 
> > Turned on that driver->owner which is struct module is not available when
> > modules are disabled. Better to depend on a driver name which is
> > always available.
> > 
> > Reported-by: Randy Dunlap <rdunlap@infradead.org>
> > Fixes: e5224f0fe2 ("devlink: add hardware messages tracing facility")
> > Signed-off-by: Jiri Pirko <jiri@mellanox.com>  
> 
> Acked-by: Randy Dunlap <rdunlap@infradead.org>

I may as well add mine too...

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve
