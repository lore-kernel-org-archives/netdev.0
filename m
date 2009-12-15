From: Daniel Mack <daniel@caiaq.de>
Subject: Re: [PATCH] wireless: wext: allocate space for NULL-termination
 for 32byte SSIDs
Date: Tue, 15 Dec 2009 18:37:14 +0800
Message-ID: <20091215103714.GK28375@buzzloop.caiaq.de>
References: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
 <20091215.014308.77044043.davem@davemloft.net>
 <1260871411.3692.4.camel@johannes.local>
 <1260871634.3692.6.camel@johannes.local>
 <20091215102035.GJ28375@buzzloop.caiaq.de>
 <1260873083.3692.8.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	dcbw@redhat.com, m.hirsch@raumfeld.com, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org, stable@kernel.org,
	linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757726AbZLOKhZ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1260873083.3692.8.camel@johannes.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 15, 2009 at 11:31:23AM +0100, Johannes Berg wrote:
> On Tue, 2009-12-15 at 18:20 +0800, Daniel Mack wrote:
> 
> > > drivers/net/wireless/libertas$ grep lbs_deb_ * | grep ssid|grep '%s'
> > > assoc.c:	lbs_deb_join("current SSID '%s', ssid length %u\n",
> > > assoc.c:	lbs_deb_join("requested ssid '%s', ssid length %u\n",
> > > assoc.c:	lbs_deb_join("ADHOC_START: SSID '%s', ssid length %u\n",
> > > scan.c:		lbs_deb_wext("set_scan, essid '%s'\n",
> > 
> > Those macros are stubbed out as nops in my setup, so they can
> > unfortunately not be the reason. I'll dig deeper :)
> 
> Well, the stack trace ought to help.

It unfortunately doesn't. The site that causes the problem does not
crash itself. It just corrupts some memory, and the actual crash happens
much later, which makes it so evil.

Daniel
