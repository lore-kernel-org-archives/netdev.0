From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 8/10] d80211: get rid of default management interface
Date: Wed, 26 Apr 2006 14:53:29 -0400
Message-ID: <20060426185324.GA7922@tuxdriver.com>
References: <20060421225314.048983000.midnight@suse.cz> <20060421205328.39BE2482C1@silver.suse.cz> <20060422024431.GJ27215@instant802.com> <20060424150148.642b057f@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:53776 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932108AbWDZSxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 14:53:49 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060424150148.642b057f@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 24, 2006 at 03:01:48PM +0200, Jiri Benc wrote:
> On Fri, 21 Apr 2006 19:44:31 -0700, Jouni Malinen wrote:
> > On Fri, Apr 21, 2006 at 10:53:28PM +0200, Jiri Benc wrote:
> > > Default management interface (wlanXap) confuses users. It is only needed for
> > > AP mode (and only until interfaces are converted to use native 802.11
> > > frames).
> > 
> > Or when using user space MLME in client mode which is something that I
> > just got working as far as scanning and association is concerned. In
> > other words, wpa_supplicant will be needing this interface..
> 
> I think we can (and should) wait with userspace MLME until the netlink
> interface is implemented.
> 
> > That sounds like something that could break multi-BSSID/SSID aware
> > hostapd. Are you saying that there would be new wlanXap like interface
> > for each BSS/VLAN interface? What are the problems this is fixing with
> > multiple AP interfaces?
> 
> Thinking about it more, only implementation problems. I was just lazy
> and implementing things the way I did seemed to be easier. My fault,
> sorry, didn't realize hostapd is aware of multiple BSSes.
> 
> > So far, hostapd has been responsible for
> > receiving all management from a single interface and then internally
> > decide which BSS/multi-SSID entry to use for each.
> > 
> > I would assume that hostapd could be changed to process frames from
> > multiple interfaces (at least if this is only for multi-BSSID, not for
> > multi-SSID/VLAN case).
> 
> There is no point in changing hostapd as this solution is temporary only
> and hostapd will need to be changed for netlink anyway.
> 
> I will fix the patch.

I'm going to skip this patch for now.  I'll merge the rest.

John
-- 
John W. Linville
linville@tuxdriver.com
