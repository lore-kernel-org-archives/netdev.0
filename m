From: "Jouni Malinen" <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
Subject: Re: support for bridging ethernet and 802.11
Date: Thu, 10 May 2007 10:25:10 -0700
Message-ID: <20070510172510.GE24712@devicescape.com>
References: <CCA1D7C0-D44A-450D-A76E-DAE792E0CB37@kernel.crashing.org> <1178816781.3806.31.camel@johannes.berg> <20070510171213.GD24712@devicescape.com> <1178817575.3806.36.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1178817575.3806.36.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2007 at 07:19:35PM +0200, Johannes Berg wrote:

> Ah forgot about that, I had only thought about AP/wired bridging. How
> would the prism driver actually do bridging in STA mode though?

If that is referring to Host AP driver, there is support for using WDS
in client mode. If the AP understands this, the client could use
standard frames for its own packets (i.e., SA=own MAC addr) and WDS
frames for frames from all other addresses. There are some experimental
modes in Host AP driver that (if I remember correctly ;-) may allow this
to be used on a single netdev (i.e., no additional netdev needed for the
WDS link) and as such, this would look like working layer 2 bridging
between wlan0 and eth0 even in managed mode.

-- 
Jouni Malinen                                            PGP id EFC895FA
