From: Mattias Nissler <mattias.nissler-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: RFC: always enable MAC80211_RC_PID?
Date: Thu, 26 Jun 2008 19:55:42 +0200
Message-ID: <1214502942.4432.6.camel@localhost>
References: <20080622125553.GB22539@cs181133002.pp.htv.fi>
	 <43e72e890806220804i347b942claae7b725231afcce@mail.gmail.com>
	 <1214298259.8967.260.camel@johannes.berg>
	 <20080624124311.GC16021@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080624124311.GC16021-re2QNgSbS3j4D6uPqz5PAwR5/fbUUdgG@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Just what I remember about the discussion that led to the ugly Makefile.

On Tue, 2008-06-24 at 15:43 +0300, Adrian Bunk wrote:
> 
> Can we get one of either:
> - all selected mac80211 algorithms are built into the mac80211 module or

IIRC, this was originally voted against because this approach would
increase kernel image size or module size unnecessarily.

> - all selected mac80211 algorithms (including the default one) are in
>   their own modules

The argument against this was that there are people who don't compile in
module autoloading, can't figure out what's wrong (in spite of the
syslog message) and complain about wireless not working...

Anyway, I always liked any of the two things you suggested better than
what we have now.

Mattias

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
