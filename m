From: "Jouni Malinen" <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
Subject: Re: support for bridging ethernet and 802.11
Date: Thu, 10 May 2007 10:12:13 -0700
Message-ID: <20070510171213.GD24712@devicescape.com>
References: <CCA1D7C0-D44A-450D-A76E-DAE792E0CB37@kernel.crashing.org> <1178816781.3806.31.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1178816781.3806.31.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2007 at 07:06:21PM +0200, Johannes Berg wrote:

> On Thu, 2007-05-10 at 11:18 -0500, Kumar Gala wrote:
> > I'm wondering how to tell if a given driver/device in the kernel  
> > supports the ability to bridge between ethernet and 802.11.  From  
> > searching the web it looks like only the prism driver/device supports  
> > this.

> Normally wireless drivers do 802.3 framing as the 802.11 standard more
> or less requires, so it should "just work". Am I missing something?

IEEE 802.11 allows only the own MAC address to be used as the source
address (addr2) when operating as a non-AP STA in BSS (client in Managed
mode). In other words, layer 2 bridging does not work properly. AP mode
and WDS links can be used for bridging without problems, but this will
of course require the driver to support these.

-- 
Jouni Malinen                                            PGP id EFC895FA
