From: "Nick Kossifidis" <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 5/5] Net: ath5k, kconfig changes
Date: Sat, 1 Sep 2007 08:58:15 +0300
Message-ID: <40f31dec0708312258h1d77fc4eu54460bf70f119d27@mail.gmail.com>
References: <2713029743177393055@pripojeni.net>
	 <280951420471148977@pripojeni.net>
	 <20070828171330.GD29343@infradead.org>
	 <40f31dec0708291838p5d33eb34p3b4432d9d270841a@mail.gmail.com>
	 <20070830123609.GA5140@tuxdriver.com>
	 <40f31dec0708301518u5ef32d13jfe1cce09656bf77d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Christoph Hellwig" <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"Jiri Slaby" <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <40f31dec0708301518u5ef32d13jfe1cce09656bf77d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2007/8/31, Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> 2007/8/30, John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>:
> > On Thu, Aug 30, 2007 at 04:38:09AM +0300, Nick Kossifidis wrote:
> > > 2007/8/28, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>:
> >
> > > > Also this whole patch seems rather pointless.  It saves only
> > > > very little and turns the driver into a complete ifdef maze.
> >
> > > Also most
> > > people will use 5212 code only, 5211 cards are on some old laptops and
> > > 5210, well i couldn't even find  a 5210 for actual testing :P
> >
> > FWIW, I'd bet dollars to donuts that distros will enable them all
> > together.
> >
> > Is saving code space the only reason to turn these off?  How much
> > space do you save?
> >
> > Is there some way you can isolate and/or limit the number of ifdef
> > blocks further?  If so, we might consider a version of this patch
> > that depends on EMBEDDED or somesuch...?
> >
> > John
>
> O.K. as a first step i'll limit 5210 code only then, just an option
> like "support older 5210 chipsets" which is going to be off by default
> instead of 3 options. It's not just saving space, it's also saving
> some runtime checks. It's not really a gain in performance though,
> most checks are done during initialization and dfs setup, i just
> thought it would be usefull to save as much cpu as possible.
>

Well after some thought i removed them all, there is no real gain from
this in most cases (that ppl will use newer 5212 chips and
combatibles).



-- 
GPG ID: 0xD21DB2DB
As you read this post global entropy rises. Have Fun ;-)
Nick
