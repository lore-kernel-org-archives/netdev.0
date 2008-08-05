From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-04
Date: Mon, 4 Aug 2008 22:17:10 -0400
Message-ID: <20080805021710.GA21731@tuxdriver.com>
References: <20080804193753.GA30345@tuxdriver.com> <20080804.150147.78586437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080804.150147.78586437.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 04, 2008 at 03:01:47PM -0700, David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Mon, 4 Aug 2008 15:37:53 -0400
> 
> > Another big round of fixes for 2.6.27.  Included is also a renaming
> > patch and some related patches that rename iwl4965 to iwlagn (reflecting
> > that is supports iwl5000 as well).
> > 
> > The other big(ger) thing here is the new ath9k driver.  It is probably
> > still far from perfect, but I'm hearing good reports on its
> > functionality and the Atheros team (and others) have already been quite
> > responsive on comments, etc.  I think it is best to go ahead and get it
> > into 2.6.27.
> > 
> > Please let me know if there are problems!
> 
> I'm holding off on this pull until the list.h changes get so me lkml
> ACKs.

Sure, np.  I created a "no-ath9k" branch in case you are feeling
frisky -- it is the same except for omitting the list.h changes,
the ath5k pci table change, and the new ath9k driver.

	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git no-ath9k

Hth!

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
