From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: RFC: Reproducible oops with lockdep on count_matching_names()
Date: Mon, 5 Nov 2007 14:03:38 +0100
Message-ID: <200711051403.39479.mb@bu3sch.de>
References: <20071101191716.GA3201@pogo> <1194264016.27652.428.camel@twins> <84144f020711050423r7a1f0e55g36c8c5ad29bfc700@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Peter Zijlstra" <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Michael Wu" <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Ingo Molnar" <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Michael Chan" <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Christoph Lameter" <clameter-sJ/iWh9BUns@public.gmane.org>
To: "Pekka Enberg" <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <84144f020711050423r7a1f0e55g36c8c5ad29bfc700-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 05 November 2007 13:23:50 Pekka Enberg wrote:
> Hi Michael,
> 
> On Sat, 2007-11-03 at 21:06 +0100, Michael Buesch wrote:
> > Who is responsible for slab btw?
> > I mean, someone should be interested in getting this bug fixed. :)
> > When using slab I see random corruptions. I think related to rmmod, but
> > I'm not sure. I don't see this with slub.
> 
> Is CONFIG_DEBUG_SLAB enabled? Usually these kind of random corruptions
> are caused by someone passing a bad pointer to kfree() or
> kmem_cache_free().

Yeah.

What I also saw was random "one-bit-errors" once and then on rmmod of modules.
I have absolutely no idea how they were caused, though (I read the freeing
codes of the stuff hundreds of times). I don't have any of the oops messages
anymore.
But I do _not_ see this behaviour with slub anymore.

-- 
Greetings Michael.
