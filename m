From: Holger Schurig <hs4233@mail.mn-solutions.de>
Subject: Re: [PATCH] net/wireless/libertas: do not call wiphy_unregister() w/o wiphy_register()
Date: Tue, 30 Mar 2010 12:59:23 +0200
Message-ID: <201003301259.23973.hs4233@mail.mn-solutions.de>
References: <1269875658-3324-1-git-send-email-daniel@caiaq.de> <201003301149.13462.hs4233@mail.mn-solutions.de> <20100330105029.GO30801@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Bing Zhao <bzhao@marvell.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Daniel Mack <daniel@caiaq.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100330105029.GO30801@buzzloop.caiaq.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I don't get your point. The patch I submitted fixes an Ooops in the
> driver, due to wrong handling of an API. What does that have to do with
> principle discussions about the frameworks in use?

I asked if there is a better method, and you said that you would test a better 
solution. That means that someone else should make a better solution.

I just pointed out that I won't be the one who creates the better solution, 
because for fundamental reasons I don't see the libertas+cfg80211 approach 
going forward. That issue has nothing to do with you or your patch, so please 
don't feel offended or confused.


Basically, I neither ack nor nak you patch. Given that it fixes an oops the 
patch should go in, and probably to stable at well. I just gave a hint, to 
make you think if you could come up with something better.



BTW, testing/fixing of failure paths in libertas as well as simplifying the 
call sequence of functions during initialisation could be quite useful.
