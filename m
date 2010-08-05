From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] cfg80211: support sysfs namespaces
Date: Thu, 05 Aug 2010 22:05:30 +0200
Message-ID: <1281038730.4058.12.camel@jlt3.sipsolutions.net>
References: <1281023115.4058.11.camel@jlt3.sipsolutions.net>
	 <m1wrs47shi.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <m1wrs47shi.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-08-05 at 12:46 -0700, Eric W. Biederman wrote:
> Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> writes:
> 
> > From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> >
> > Enable using network namespaces with
> > wireless devices even when sysfs is
> > enabled using the same infrastructure
> > that was built for netdevs.
> 
> Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> This looks reasonable.  I assume you have tested this and it is
> working now?

Yes, I tested it. Was missing the no-op device_rename() at first, but
now it works.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
