From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH v3 3/5] usbnet: smsc95xx: fix memory leak in smsc95xx_suspend
Date: Tue, 6 Nov 2012 13:58:32 +0000
Message-ID: <CAKh2mn4HvxeJ-RasNQX5RfJhHxw9SpJ7y-Sy-jhdVuPa_E7KnA@mail.gmail.com>
References: <1352166341-27616-1-git-send-email-ming.lei@canonical.com>
	<1352166341-27616-4-git-send-email-ming.lei@canonical.com>
	<CAKh2mn52HCFE8JSRJZ95m8qimPP0d4hx8SP3yExTsi+RYfJwRg@mail.gmail.com>
	<CACVXFVPhYaBcr+V4W1-fSrLFVMMVo8vUv=eaKu2y_LjZ-EtnwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	Steve Glendinning <steve.glendinning@shawell.net>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40688 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445Ab2KFN6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 08:58:34 -0500
Received: by mail-ee0-f46.google.com with SMTP id b15so263668eek.19
        for <netdev@vger.kernel.org>; Tue, 06 Nov 2012 05:58:33 -0800 (PST)
In-Reply-To: <CACVXFVPhYaBcr+V4W1-fSrLFVMMVo8vUv=eaKu2y_LjZ-EtnwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> BTW, I just saw the smsc95xx datasheet and the vendor's driver
> source code, and found the chip supports runtime PM well
> (remote wakeup on 'good packet' or link change), so do you
> plan to implement that?

Yes, I do plan to implement this.  Note that this feature is only
supported on some product variants, for example LAN9500A, so it won't
benefit all smsc95xx users.
