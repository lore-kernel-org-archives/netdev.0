From: Fabio Estevam <festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2] drivers: net: Fix dependency for EEPROM_93CX6
Date: Thu, 5 Jan 2012 16:06:54 -0200
Message-ID: <CAOMZO5AuZ_MHW3C1uNK7PyRz=XRHXhn2pvKCwk7iXLDd0YkDOQ@mail.gmail.com>
References: <1325770673-17309-1-git-send-email-festevam@gmail.com>
	<4F05CBA9.1070602@lwfinger.net>
	<20120105.122004.1170447281304011158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120105.122004.1170447281304011158.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 5, 2012 at 3:20 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> Right, this is definitely the wrong fix, "select" is the right way to
> fix this because no user should have to know the gory details of what
> random odd config variables have to be on already in order to turn on
> support for a device they are interested in.
>
> Fix this right, by using "select MISC_DEVICES"

I have tried selecting MISC_DEVICES in the Kconfig's, but the warning remains.

I agree with Ben's comment: "That seems like a bug, since MISC_DEVICES
doesn't by itself select any
code.  (It's also not a meaningful category and maybe ought not to be an
option at all.)"

Regards,

Fabio Estevam
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
