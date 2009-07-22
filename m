From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Wed, 22 Jul 2009 09:40:56 +0100
Message-ID: <20090722094056.0ca0e122@lxorguk.ukuu.org.uk>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com>
	<1248184373.6558.15.camel@localhost.localdomain>
	<200907221137.07005.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ext Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ext Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
To: "=?ISO-8859-14?B?UultaQ==?= Denis-Courmont"
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200907221137.07005.remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> provides data path (IPv4 or IPv6 packets) and flow control. But GPRS context 
> credentials, IP/DNS parameters, setup/teardown, etc, are missing. I am not 
> sure where the user/kernel split should be here...

As much as possible in user space for set up and tear down processing of
connections (negotiation etc). I've been poking in the background at a
kernel side GSM mux implementation but keep getting side tracked into
other work. other than the mux (where you have 3G stuff with high data
rates to demux efficiently) I'm not sure much else should be kernel side.

User space platform code yes - kernel no.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
