From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH - diffstat only] include/net: Remove extern from
 function prototypes
Date: Wed, 24 Jul 2013 18:41:20 -0700
Message-ID: <1374716480.1924.18.camel@joe-AO722>
References: <1374602291.3387.17.camel@joe-AO722>
	 <kspuuk$k2v$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <kspuuk$k2v$1@ger.gmane.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-07-25 at 01:27 +0000, Cong Wang wrote:
> On Tue, 23 Jul 2013 at 17:58 GMT, Joe Perches <joe@perches.com> wrote:

You dropped the author from the cc list.
Always reply to the author.

> > Function prototypes don't need to be declared
> > extern in .h files.  It's assumed by the compiler
> > and is as unnecessary as using auto is when
> > declaring automatic/local variables in a block.
> >
> Since we all know this, why bother it?

If everyone knew this, new ones wouldn't be added.
But a lot are.

Removing extern makes prototypes shorter and more readable.
More prototypes fit in a single line
More arguments fit on a multi-line prototypes.

> Having "extern" doesn't harm
> readability, instead it probably helps.

Sure, just like auto does.  Why isn't that used?

> > I believe it makes grepping for extern useful as
> > all the matches are actual variables and structs.
> You need a semantic tool.

No, not really.  I'm fairly comfortable with spatch.
spatch takes a long time to run for a lot of things.
