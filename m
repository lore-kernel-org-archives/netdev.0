From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: RFC: Reproducible oops with lockdep on count_matching_names()
Date: Sat, 3 Nov 2007 21:06:54 +0100
Message-ID: <200711032106.56569.mb@bu3sch.de>
References: <20071101191716.GA3201@pogo> <1194001120.27652.353.camel@twins> <43e72e890711031258g4ccd9cd0hc4520e9473f6ce49@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Peter Zijlstra" <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"Michael Wu" <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Ingo Molnar" <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Michael Chan" <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <43e72e890711031258g4ccd9cd0hc4520e9473f6ce49-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 03 November 2007 20:58:09 Luis R. Rodriguez wrote:
> I was using SLAB and ran into other strange oops, as the one below,
> but after switching to SLUB, after Michael Buesch's suggestion that
> one went away... The lockdep segfault is still present, however.

Who is responsible for slab btw?
I mean, someone should be interested in getting this bug fixed. :)
When using slab I see random corruptions. I think related to rmmod, but
I'm not sure. I don't see this with slub.

-- 
Greetings Michael.
