From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless 2012-06-22
Date: Sat, 23 Jun 2012 00:11:03 -0400
Message-ID: <20120623041103.GA29801@tuxdriver.com>
References: <20120622201716.GB13918@tuxdriver.com>
 <20452.64701.760819.559191@gargle.gargle.HOWL>
 <20453.302.671438.533390@gargle.gargle.HOWL>
 <20120622.165611.2220193371527786713.davem@davemloft.net>
 <20453.9687.225096.194368@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sujith Manoharan <c_manoha@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20453.9687.225096.194368@gargle.gargle.HOWL>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 23, 2012 at 07:41:35AM +0530, Sujith Manoharan wrote:
> David Miller wrote:
> > From: Sujith Manoharan <c_manoha@qca.qualcomm.com>
> > Date: Sat, 23 Jun 2012 05:05:10 +0530
> > 
> > > Sujith Manoharan wrote:
> > >> John W. Linville wrote:
> > >> > Mohammed Shafi Shajakhan (1):
> > >> >       ath9k_hw: avoid possible infinite loop in ar9003_get_pll_sqsum_dvc
> > >> 
> > >> Um, this commit doesn't really fix anything - the timeout is also
> > >> arbitrary. Can you remove this from the 3.5 queue ? Thanks.
> > > 
> > > A review of the patch later, I think it's good. At least there's a
> > > WARN_ON_ONCE() to indicate the situation in which the measurement fails.
> > > It might come in handy as a debugging aid.
> > 
> > Thanks for wasting our time.
> > 
> > Make these determinations when changes to into John's tree, not
> > later when he asks me to pull them into mine.
> 
> The patch was under review:
> http://marc.info/?l=linux-wireless&m=134001371002288&w=2

Quibbling over the exact number of iterations for a timeout didn't
seem is important as avoiding an endless loop...

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
