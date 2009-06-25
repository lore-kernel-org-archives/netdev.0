From: Jesper Dangaard Brouer <jdb-4UpuNZONu4c@public.gmane.org>
Subject: Re: [PATCH 07/10] decnet: Use rcu_barrier() on module unload.
Date: Thu, 25 Jun 2009 13:52:09 +0200
Message-ID: <1245930729.24921.67.camel@localhost.localdomain>
References: <20090623150330.22490.87327.stgit@localhost>
	 <20090623150429.22490.15113.stgit@localhost>
	 <4A41C67E.8070301@googlemail.com>
	 <1245843884.6695.54.camel@localhost.localdomain>
	 <1245845367.24921.3.camel@localhost.localdomain>
	 <5A680E0A-EFEB-44EA-9F06-F338E6CBD6D1@googlemail.com>
Reply-To: jdb-4UpuNZONu4c@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dougthompson-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org,
	shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tytso-3s7WtUTddSA@public.gmane.org, adilger-xsfywfwIY+M@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Chrissie Caulfield <christine.caulfield-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5A680E0A-EFEB-44EA-9F06-F338E6CBD6D1-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-06-24 at 14:50 +0100, Chrissie Caulfield wrote:
> I don't have any objection to the patch at all, 

Thus assuming an:

Acked-by: Chrissie Caulfield <christine.caulfield-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>

(wondering if patchworks picks this up...)

> it just seemed a  
> little odd to deliberately add code inside #if 0 ;-)

Yes, but it makes sense if you want to fix that code path later on.

And I'm not the only one who have added code here... git blame:

fa34ddd7 (Thomas Graf              2007-03-22 11:57:46 -0700 2401)
457c4cbc (Eric W. Biederman        2007-09-12 12:01:34 +0200 2413)

Cheers,
                                  -- 
                    Med venlig hilsen / Best regards
                              Jesper Brouer
                            ComX Networks A/S
                         Linux Network developer
                       Cand. Scient Datalog / MSc.
                    Author of http://adsl-optimizer.dk
               LinkedIn: http://www.linkedin.com/in/brouer
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
