From: Stefan Rompf <stefan@loplof.de>
Subject: Re: wireless: recap of current issues (configuration)
Date: Sun, 15 Jan 2006 18:53:31 +0100
Message-ID: <200601151853.31710.stefan@loplof.de>
References: <20060113195723.GB16166@tuxdriver.com> <200601151340.10730.stefan@loplof.de> <56187.84.135.205.30.1137340292.squirrel@secure.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933541AbWAORyO@vger.kernel.org>
To: "Johannes Berg" <johannes@sipsolutions.net>
In-Reply-To: <56187.84.135.205.30.1137340292.squirrel@secure.sipsolutions.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag 15 Januar 2006 16:51 schrieb Johannes Berg:

> Isn't that rather a question of having good user-space tools that make
> deactivating one type of interface and activating another seamless?

Well, it's always easy to point to userspace. However, unregister_netdev() 
initiates a lot of actions. IPv4 addresses and routes are removed, same for 
IPv6, IPX, Appletalk etc. Stacked VLAN devices are recursively unregistered 
(even though I have not tried yet if it works when I create VLANs over 802.3 
emulated wlan interfaces ;-), udev bloat runs. And all this stuff has to be 
restored by the nifty new configuration utility, possibly including ifindex 
and future protocols.

This is from my usage pattern that I want to go into monitor mode on current 
channel, look at some packets and return to the association without losing 
layer 3 configuration.

So after all, it is IMHO way less painful to handle a mode change in the 
kernel.

Stefan
