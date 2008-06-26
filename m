From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: RFC: always enable MAC80211_RC_PID?
Date: Thu, 26 Jun 2008 14:35:42 -0700
Message-ID: <43e72e890806261435t3d06e955x590a6fafb223bbca@mail.gmail.com>
References: <20080622125553.GB22539@cs181133002.pp.htv.fi>
	 <43e72e890806220804i347b942claae7b725231afcce@mail.gmail.com>
	 <1214298259.8967.260.camel@johannes.berg>
	 <20080624124311.GC16021@cs181140183.pp.htv.fi>
	 <20080624211222.GB25892@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Adrian Bunk" <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Adrian Bunk" <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Rindjunsky, Ron" <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Winkler, Tomas" <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080624211222.GB25892-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 24, 2008 at 2:12 PM, John W. Linville
<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> On Tue, Jun 24, 2008 at 03:43:14PM +0300, Adrian Bunk wrote:
>
>> Can we get one of either:
>> - all selected mac80211 algorithms are built into the mac80211 module or
>
> This seems fine to me.

OK so just to be clear -- moving forward we strive to not allow driver
specific rate control algorithms and push out current ones into
mac80211? This would mean we don't have to *cleanup* support for
driver specific RCs but instead just have them stashed in as part of
the build. The difficulty here lies in ensuring they do work for well
for other drivers but I do agree it strives to cleanup RC code. I
think vendors also tend to use a few driver specific tweaks to boost
their own throughput in their own RCs though. Can't say for sure right
now of specific details but I'll try to get back to you with them.
Perhaps Tomas can say more about that for iwl's RCs.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
