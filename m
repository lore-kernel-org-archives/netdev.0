From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH net-next 1/3] lib: Resizable, Scalable,
 Concurrent Hash Table
Date: Fri, 1 Aug 2014 11:32:55 +0100
Message-ID: <20140801103255.GA7331@casper.infradead.org>
References: <cover.1406882738.git.tgraf@suug.ch>
 <15a766adefc269dd26001474e9b67dbbd0d5bc82.1406882738.git.tgraf@suug.ch>
 <20140801102632.GA19476@server.your-server.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140801102632.GA19476-vNV1b4aEi7DjYz8Lru2jqd10k2aWwXN4@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 08/01/14 at 12:26pm, Patrick McHardy wrote:
> On Fri, Aug 01, 2014 at 10:51:58AM +0200, Thomas Graf wrote:
> > --- /dev/null
> > +++ b/include/linux/rhashtable.h
> > @@ -0,0 +1,213 @@
> > +/*
> > + * Resizable, Scalable, Concurrent Hash Table
> > + *
> > + * Copyright (c) 2014 Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> > + *
> > + * Based on the following paper by Josh Triplett, Paul E. McKenney
> > + * and Jonathan Walpole:
> > + * https://www.usenix.org/legacy/event/atc11/tech/final_files/Triplett.pdf
> > + *
> > + * Code partially derived from nft_hash:
> > + * Copyright (c) 2008-2014 Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> 
> Minor request: german copyright law as an assumption of authorship for
> authors marked in the work. When doing GPL enforcement I would prefer
> any discussions about what derived from specifically means in this
> case and whether this constitutes a normal statement of authorship,
> and since this clearly contains a lot of literal code I have written,
> please change this to something like
> 
> Copyright ... Thomas Graf
> Copyright ... Patrick McHardy
> 
> ...
> 
> Code partially derived from nft_hash.
> 
> Thanks!

Sure, it was not my intention to hide ownership in any way.
