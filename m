From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 1/2] wl12xx: switch to %pM to print the mac address
Date: Thu, 17 Sep 2009 08:55:21 -0400
Message-ID: <20090917125521.GA2577@tuxdriver.com>
References: <1253146059-4169-1-git-send-email-plagnioj@jcrosoft.com> <1253150571.4989.33.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42354 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532AbZIQNAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 09:00:33 -0400
Content-Disposition: inline
In-Reply-To: <1253150571.4989.33.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2009 at 02:22:51AM +0100, Ben Hutchings wrote:
> On Thu, 2009-09-17 at 02:07 +0200, Jean-Christophe PLAGNIOL-VILLARD
> wrote:
> > Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> > ---
> >  drivers/net/wireless/wl12xx/wl1271_main.c |    3 +--
> >  1 files changed, 1 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/wireless/wl12xx/wl1271_main.c b/drivers/net/wireless/wl12xx/wl1271_main.c
> > index d9169b4..f6f8895 100644
> > --- a/drivers/net/wireless/wl12xx/wl1271_main.c
> > +++ b/drivers/net/wireless/wl12xx/wl1271_main.c
> > @@ -644,11 +644,10 @@ static int wl1271_op_config_interface(struct ieee80211_hw *hw,
> >  {
> >  	struct wl1271 *wl = hw->priv;
> >  	struct sk_buff *beacon;
> > -	DECLARE_MAC_BUF(mac);
> >  	int ret;
> >  
> >  	wl1271_debug(DEBUG_MAC80211, "mac80211 config_interface bssid %s",
> > -		     print_mac(mac, conf->bssid));
> > +		     printf("%pM", conf->bssid);
> >  	wl1271_dump_ascii(DEBUG_MAC80211, "ssid: ", conf->ssid,
> >  			  conf->ssid_len);
> >  
> 
> That isn't even syntactically valid, let alone correct.

Ugh, you're right -- remind me not to ACK things before bed...

Jean-Christophe posted a new patch that looked better, although it
probably needs to be rebased on this one since I think Dave applied
it after my (misguided) ACK.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
