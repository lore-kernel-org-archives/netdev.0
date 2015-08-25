From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 1/2] usbnet: Get EVENT_NO_RUNTIME_PM bit before it is cleared
Date: Tue, 25 Aug 2015 16:16:07 +0200
Message-ID: <87oahv78t4.fsf@nemi.mork.no>
References: <55AD3A41.2040100@rosalab.ru>
	<1440447223-15945-1-git-send-email-eugene.shatokhin@rosalab.ru>
	<1440447223-15945-2-git-send-email-eugene.shatokhin@rosalab.ru>
	<1440507709.13824.6.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eugene Shatokhin <eugene.shatokhin-irhHPgl+04UvJsYlp49lxw@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1440507709.13824.6.camel-IBi9RG/b67k@public.gmane.org> (Oliver Neukum's message of
	"Tue, 25 Aug 2015 15:01:49 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org> writes:

> On Mon, 2015-08-24 at 23:13 +0300, Eugene Shatokhin wrote:
>> It is needed to check EVENT_NO_RUNTIME_PM bit of dev->flags in
>> usbnet_stop(), but its value should be read before it is cleared
>> when dev->flags is set to 0.
>
> Can we agree that this at least is good and should go upstream
> and into stable?

I definitely agree.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
