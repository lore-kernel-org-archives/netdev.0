From: "Pekka Enberg" <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
Subject: Re: RFC: Reproducible oops with lockdep on count_matching_names()
Date: Mon, 5 Nov 2007 14:23:50 +0200
Message-ID: <84144f020711050423r7a1f0e55g36c8c5ad29bfc700@mail.gmail.com>
References: <20071101191716.GA3201@pogo> <1194001120.27652.353.camel@twins>
	 <43e72e890711031258g4ccd9cd0hc4520e9473f6ce49@mail.gmail.com>
	 <200711032106.56569.mb@bu3sch.de> <1194264016.27652.428.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael Buesch" <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Michael Wu" <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Ingo Molnar" <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Michael Chan" <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Christoph Lameter" <clameter-sJ/iWh9BUns@public.gmane.org>
To: "Peter Zijlstra" <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1194264016.27652.428.camel@twins>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Michael,

On Sat, 2007-11-03 at 21:06 +0100, Michael Buesch wrote:
> Who is responsible for slab btw?
> I mean, someone should be interested in getting this bug fixed. :)
> When using slab I see random corruptions. I think related to rmmod, but
> I'm not sure. I don't see this with slub.

Is CONFIG_DEBUG_SLAB enabled? Usually these kind of random corruptions
are caused by someone passing a bad pointer to kfree() or
kmem_cache_free().

                                  Pekka
