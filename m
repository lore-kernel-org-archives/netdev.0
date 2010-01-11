From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: REGRESSION for RT2561/RT61 in 2.6.33
Date: Mon, 11 Jan 2010 10:46:46 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1001111045240.2873-100000@iolanthe.rowland.org>
References: <1263222695.29743.1.camel@johannes.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Gertjan van Wingerde <gwingerde@gmail.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753545Ab0AKPqs@vger.kernel.org>
In-Reply-To: <1263222695.29743.1.camel@johannes.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 11 Jan 2010, Johannes Berg wrote:

> Alan,
> 
> > The card doesn't work.  Although the firmware load appears to
> > succeed, "iwconfig wlan0" says no wireless extensions present.
> 
> You need to set CONFIG_CFG80211_WEXT (it is default y).
> 
> > The only clue I can offer is that "rmmod rt61pci" hangs in 
> > wiphy_unregister() during the wait_event() loop near the start,
> > because 
> > rdev->opencount is equal to -1.  This suggests a refcounting imbalance
> > 
> > of some sort.
> 
> Good point, that's a bug that will go away with CONFIG_CFG80211_WEXT,
> I'll send a fix.

Many thanks.  I'll test the patch and the config option tonight and
report back tomorrow.

Alan Stern
