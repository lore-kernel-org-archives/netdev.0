From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Libertas: fix buffer overflow in lbs_get_essid()
Date: Wed, 16 Dec 2009 17:19:12 -0800
Message-ID: <1261012752.17721.8.camel@localhost.localdomain>
References: <1260936778-2096-1-git-send-email-daniel@caiaq.de>
	 <1260982667.2179.9.camel@localhost.localdomain>
	 <20091216231508.GX28375@buzzloop.caiaq.de>
	 <20091217010114.GA2913@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@caiaq.de>, linux-kernel@vger.kernel.org,
	Holger Schurig <holgerschurig@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Maithili Hinge <maithili@marvell.com>,
	Kiran Divekar <dkiran@marvell.com>,
	Michael Hirsch <m.hirsch@raumfeld.com>, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	stable@kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936037AbZLQBeV@vger.kernel.org>
In-Reply-To: <20091217010114.GA2913@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-12-16 at 20:01 -0500, John W. Linville wrote:
> On Thu, Dec 17, 2009 at 07:15:08AM +0800, Daniel Mack wrote:
> > On Wed, Dec 16, 2009 at 08:57:47AM -0800, Dan Williams wrote:
> > > On Wed, 2009-12-16 at 05:12 +0100, Daniel Mack wrote:
> > > > The libertas driver copies the SSID buffer back to the wireless core and
> > > > appends a trailing NULL character for termination. This is
> > > > 
> > > > a) unnecessary because the buffer is allocated with kzalloc and is hence
> > > >    already NULLed when this function is called, and
> > > > 
> > > > b) for priv->curbssparams.ssid_len == 32, it writes back one byte too
> > > >    much which causes memory corruptions.
> > > > 
> > > > Fix this by removing the extra write.
> > > 
> > > Acked-by: Dan Williams <dcbw@redhat.com>
> > 
> > Thanks, everyone. Who will care to pick an queue this one?
> 
> Is there some reason it wouldn't be me?

No, it should be you.  Please suck it into your 2.6.33 patchset and
we'll cc to stable when it hits linus I guess.

Dan
