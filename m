From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] bluetooth: Convert BT_DBG to pr_debug
Date: Sun, 12 Feb 2012 23:24:44 -0800
Message-ID: <1329117884.31068.1.camel@joe2Laptop>
References: <cover.1329102581.git.joe@perches.com>
	 <90fbd8a0b800c83f5ad1df7889dc9b11d7d9c588.1329102581.git.joe@perches.com>
	 <1329115057.28848.52.camel@aeonflux> <1329115904.30878.7.camel@joe2Laptop>
	 <1329117558.28848.53.camel@aeonflux>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1329117558.28848.53.camel@aeonflux>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-02-13 at 08:19 +0100, Marcel Holtmann wrote:
> > > The only useful change would be to move to dev_printk, but we are not
> > > there yet.
> > Maybe dev_dbg, but there isn't always an
> > appropriate device * available.
> exactly. And that needs to be fixed first.

Doubtful.  Passing extra arguments around for
debug statements that aren't always emitted
can be wasteful.

cheers, Joe
