From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH v2 04/16] wl1251: implement hardware ARP filtering
Date: Tue, 10 Dec 2013 10:59:37 +0100
Message-ID: <20131210095937.GC9741@unicorn.suse.cz>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
 <1386494714-21070-5-git-send-email-pali.rohar@gmail.com>
 <20131210092916.GD22756@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
	Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, sre@ring0.de, joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>,
	David Gnedt <david.gnedt@davizone.at>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131210092916.GD22756@amd.pavel.ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 10, 2013 at 10:29:16AM +0100, Pavel Machek wrote:
> >  
> > +int wl1251_acx_arp_ip_filter(struct wl1251 *wl, bool enable, __be32 address)
> > +{
> > +	struct wl1251_acx_arp_filter *acx;
> > +	int ret;
> 
> Is it good idea to use be32 for IP address? AFAICT IPv4 addresses
> really don't have edianity. Perhaps u32 is better?

If they are known to be in network byte ordering, they do (as NBO is the
same as BE).

                                                         Michal Kubecek
