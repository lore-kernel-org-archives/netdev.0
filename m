From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net/wireless/libertas: do not call wiphy_unregister()
 w/o wiphy_register()
Date: Tue, 30 Mar 2010 10:04:33 -0700
Message-ID: <1269968673.3019.37.camel@localhost.localdomain>
References: <1269875658-3324-1-git-send-email-daniel@caiaq.de>
	 <201003301149.13462.hs4233@mail.mn-solutions.de>
	 <20100330105029.GO30801@buzzloop.caiaq.de>
	 <201003301259.23973.hs4233@mail.mn-solutions.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>, libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Holger Schurig <hs4233-x6+DxXLjN1AJvtFkdXX2Hg4jNU5vUVPG@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201003301259.23973.hs4233-x6+DxXLjN1AJvtFkdXX2Hg4jNU5vUVPG@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-03-30 at 12:59 +0200, Holger Schurig wrote:
> > I don't get your point. The patch I submitted fixes an Ooops in the
> > driver, due to wrong handling of an API. What does that have to do with
> > principle discussions about the frameworks in use?
> 
> I asked if there is a better method, and you said that you would test a better 
> solution. That means that someone else should make a better solution.
> 
> I just pointed out that I won't be the one who creates the better solution, 
> because for fundamental reasons I don't see the libertas+cfg80211 approach 
> going forward. That issue has nothing to do with you or your patch, so please 
> don't feel offended or confused.

Fine; just rip out the mesh code and do the vanilla cfg80211 conversion
for infra & adhoc, and we'll add the mesh code back later.  I don't have
time to do the cfg80211 bits, neither do the OLPC guys (AFAIK), so lets
take advantage of your willingness to do this and just move the driver
forward.

Dan

> 
> Basically, I neither ack nor nak you patch. Given that it fixes an oops the 
> patch should go in, and probably to stable at well. I just gave a hint, to 
> make you think if you could come up with something better.
> 
> 
> 
> BTW, testing/fixing of failure paths in libertas as well as simplifying the 
> call sequence of functions during initialisation could be quite useful.
> 
> _______________________________________________
> libertas-dev mailing list
> libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> http://lists.infradead.org/mailman/listinfo/libertas-dev


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
