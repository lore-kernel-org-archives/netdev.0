From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Sun, 12 Jun 2011 04:46:58 +0100
Message-ID: <1307850418.22348.628.camel@localhost>
References: <20110611200625.GB14582@kroah.com>
	 <1307829318-18246-1-git-send-email-marius@kotsbak.com>
	 <20110611.162711.907394751613071878.davem@davemloft.net>
	 <20110611.162942.1706711069327005315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110611.162942.1706711069327005315.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2011-06-11 at 16:29 -0700, David Miller wrote:
> From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Date: Sat, 11 Jun 2011 16:27:11 -0700 (PDT)
> 
> > From: "Marius B. Kotsbak" <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date: Sat, 11 Jun 2011 23:55:18 +0200
> > 
> >> Introducing driver for the network port of Samsung Kalmia based USB LTE modems.
> >> It has also an ACM interface that previous patches associates with the "option"
> >> module. To access those interfaces, the modem must first be switched from modem
> >> mode using a tool like usb_modeswitch.
> >> 
> >> As the proprietary protocol has been discovered by watching the MS Windows driver
> >> behavior, there might be errors in the protocol handling, but stable and fast
> >> connection has been established for hours with Norwegian operator NetCom that
> >> distributes this modem with their LTE/4G subscription.
> >> 
> >> More and updated information about how to use this driver is available here:
> >> 
> >> http://www.draisberghof.de/usb_modeswitch/bb/viewtopic.php?t=465
> >> https://github.com/mkotsbak/Samsung-GT-B3730-linux-driver
> >> 
> >> Signed-off-by: Marius B. Kotsbak <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
> > 
> > Applied, thanks.
> 
> Actually, reverted.
> 
> There's a typo in your Makefile patch, and because of this it
> won't even build the new driver.
[...]

Surely the error is in the Kconfig - the 'CONFIG_' prefix should not be
there.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
