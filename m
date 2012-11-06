From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v3 3/5] usbnet: smsc95xx: fix memory leak in smsc95xx_suspend
Date: Tue, 6 Nov 2012 22:08:56 +0800
Message-ID: <CACVXFVMoWVbhp=2NYED6UfHZ+sR5tmTUTH=oBcR3FUuX0=+eYw@mail.gmail.com>
References: <1352166341-27616-1-git-send-email-ming.lei@canonical.com>
	<1352166341-27616-4-git-send-email-ming.lei@canonical.com>
	<CAKh2mn52HCFE8JSRJZ95m8qimPP0d4hx8SP3yExTsi+RYfJwRg@mail.gmail.com>
	<CACVXFVPhYaBcr+V4W1-fSrLFVMMVo8vUv=eaKu2y_LjZ-EtnwQ@mail.gmail.com>
	<CAKh2mn4HvxeJ-RasNQX5RfJhHxw9SpJ7y-Sy-jhdVuPa_E7KnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	Steve Glendinning <steve.glendinning@shawell.net>
To: Steve Glendinning <steve@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:47785 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628Ab2KFOI6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 09:08:58 -0500
In-Reply-To: <CAKh2mn4HvxeJ-RasNQX5RfJhHxw9SpJ7y-Sy-jhdVuPa_E7KnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 6, 2012 at 9:58 PM, Steve Glendinning <steve@shawell.net> w=
rote:
>> BTW, I just saw the smsc95xx datasheet and the vendor's driver
>> source code, and found the chip supports runtime PM well
>> (remote wakeup on 'good packet' or link change), so do you
>> plan to implement that?
>
> Yes, I do plan to implement this.

Good news, :-)

> Note that this feature is only
> supported on some product variants, for example LAN9500A, so it won't
> benefit all smsc95xx users.

Right.  Looks remote wakeup on =93Link Status Change=94 (SUSPEND1)
can be supported by all smsc95xx , and remote wakeup on 'good
packets'(SUSPEND3) is only supported by LAN9500A.

Thanks,
--
Ming Lei


Thanks,
--
Ming Lei
