From: Daniel Mack <daniel@caiaq.de>
Subject: Re: [PATCH] net/wireless/libertas: do not call wiphy_unregister()
 w/o wiphy_register()
Date: Tue, 30 Mar 2010 12:50:29 +0200
Message-ID: <20100330105029.GO30801@buzzloop.caiaq.de>
References: <1269875658-3324-1-git-send-email-daniel@caiaq.de>
 <201003300849.07441.hs4233@mail.mn-solutions.de>
 <20100330085253.GL30801@buzzloop.caiaq.de>
 <201003301149.13462.hs4233@mail.mn-solutions.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Bing Zhao <bzhao@marvell.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Holger Schurig <hs4233@mail.mn-solutions.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201003301149.13462.hs4233@mail.mn-solutions.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 30, 2010 at 11:49:13AM +0200, Holger Schurig wrote:
> > If there's any better solution, I'd happily test it.
> 
> Not from me, unfortunately. I'm not really interested into getting full 
> cfg80211 into Libertas. That is, until either _one_ of this two options 
> happen:
> 
> * someone that actually uses/wants the proprietary Libertas mesh steps  
> forward and says "We'll look after this and make it work with cfg80211"
> * we remove the proprietary Libertas mesh support
> 
> That is: I won't work on Libertas mesh. I can't justify this time investment 
> with my employer for something that I'll never need. For my device, my own 
> version of Libertas + cfg80211 (without any WEXT anymore) works quite nice.
> 
> 
> So, if neither of the above things happens, then Libertas will work for the 
> rest of the world with WEXT, as it did before.

I don't get your point. The patch I submitted fixes an Ooops in the
driver, due to wrong handling of an API. What does that have to do with
principle discussions about the frameworks in use?

Daniel
