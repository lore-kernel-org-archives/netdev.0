From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Wed, 23 Feb 2005 00:15:54 +0100
Message-ID: <20050222231554.GH31837@postel.suug.ch>
References: <1106747313.1107.7.camel@jzny.localdomain> <1108134446.5523.22.camel@ganymede> <1108215923.1126.132.camel@jzny.localdomain> <1108246033.7554.18.camel@ganymede> <20050212223204.GG31837@postel.suug.ch> <1108340618.14978.66.camel@ganymede> <20050214142710.GI31837@postel.suug.ch> <1108499294.5465.22.camel@ganymede> <20050215204723.GM31837@postel.suug.ch> <1109108440.5712.17.camel@ganymede>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
To: Dan Siemon <dan@coverfire.com>
Content-Disposition: inline
In-Reply-To: <1109108440.5712.17.camel@ganymede>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > The NLHDR_COMMON must stay first, the ordering of the others doesn't
> > matter.
> 
> That could be a problem.  The GObject struct must be at the start so
> that all sub-classes can be operated on with the g_object_ functions.
> The only way to make these objects work with your caching scheme would
> be to make a sub-class of GObject with the caching information.  This
> would have the benefit of adding ref counting etc.

It's not a problem, as you note we can put the gobject information
into NLHDR_COMMON. I'm not focusing on such bindings but if you want
to reuse my code, feel free.
