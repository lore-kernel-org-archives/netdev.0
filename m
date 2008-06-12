From: Luis Carlos Cobo <luisca-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC] Do not activate promiscuous mode on wlan interfaces for
	bridging.
Date: Thu, 12 Jun 2008 11:10:50 -0700
Message-ID: <1213294251.6615.5.camel@localhost>
References: <1213232760.6645.24.camel@localhost>
	 <20080612053323.GC4919@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, bridge-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jouni Malinen <j@w1.fi>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080612053323.GC4919-mgr6C1c9aYeHXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thank you very much for your comments Jouni.

On Thu, 2008-06-12 at 08:33 +0300, Jouni Malinen wrote:
> Whether the "promiscuous mode" is really a suitable name for this mode
> is another question, though, since there are more ways to be
> promiscuous in wireless networks than wired.. ;-)

Indeed, but the bridge sets promiscuous mode, not monitor. This means
that the device will receive every frame within its configured BSS
whether it is addressed to it or not. For an AP actually this mode
should make no difference, since every frame not coming from the AP is
addressed to the AP.


> This is not strictly speaking correct. 4-address frame format (WDS) can
> be used in other (non-AP) modes, too. Anyway, they do not require the
> interface to be in promiscuous mode since addr1 of the frames is the
> unicast address of the receiving device regardless of the original
> destination address.

Agreed, will reword that.

-- 
Luis Carlos Cobo Rus       GnuPG ID: 44019B60
cozybit Inc.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
