From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 1/2] wl12xx: switch to %pM to print the mac address
Date: Thu, 17 Sep 2009 16:42:08 +0200
Message-ID: <20090917144208.GH29905@game.jcrosoft.org>
References: <1253146059-4169-1-git-send-email-plagnioj@jcrosoft.com>
 <1253150571.4989.33.camel@localhost>
 <20090917125521.GA2577@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:33298 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751832AbZIQOzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 10:55:00 -0400
Content-Disposition: inline
In-Reply-To: <20090917125521.GA2577@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08:55 Thu 17 Sep     , John W. Linville wrote:
> On Thu, Sep 17, 2009 at 02:22:51AM +0100, Ben Hutchings wrote:
> > On Thu, 2009-09-17 at 02:07 +0200, Jean-Christophe PLAGNIOL-VILLARD
> > wrote:
> > > Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> > > ---
> > >  drivers/net/wireless/wl12xx/wl1271_main.c |    3 +--
> > >  1 files changed, 1 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/drivers/net/wireless/wl12xx/wl1271_main.c b/drivers/net/wireless/wl12xx/wl1271_main.c
> > > index d9169b4..f6f8895 100644
> > > --- a/drivers/net/wireless/wl12xx/wl1271_main.c
> > > +++ b/drivers/net/wireless/wl12xx/wl1271_main.c
> > > @@ -644,11 +644,10 @@ static int wl1271_op_config_interface(struct ieee80211_hw *hw,
> > >  {
> > >  	struct wl1271 *wl = hw->priv;
> > >  	struct sk_buff *beacon;
> > > -	DECLARE_MAC_BUF(mac);
> > >  	int ret;
> > >  
> > >  	wl1271_debug(DEBUG_MAC80211, "mac80211 config_interface bssid %s",
> > > -		     print_mac(mac, conf->bssid));
> > > +		     printf("%pM", conf->bssid);
> > >  	wl1271_dump_ascii(DEBUG_MAC80211, "ssid: ", conf->ssid,
> > >  			  conf->ssid_len);
> > >  
> > 
> > That isn't even syntactically valid, let alone correct.
> 
> Ugh, you're right -- remind me not to ACK things before bed...
> 
> Jean-Christophe posted a new patch that looked better, although it
> probably needs to be rebased on this one since I think Dave applied
> it after my (misguided) ACK.
ok I'll do asap really sorry

Best Regards,
J.
