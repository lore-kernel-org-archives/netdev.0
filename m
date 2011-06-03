From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] TODO FLAG_POINTTOPOINT => FLAG_WWAN? usbnet/cdc_ncm: mark ncm devices as "mobile broadband devices" with FLAG_WWAN
Date: Fri, 03 Jun 2011 14:31:18 +0200
Message-ID: <87sjrrxfjd.fsf@nemi.mork.no>
References: <1306922913-17803-1-git-send-email-metze@samba.org>
	<201106031201.21933.oneukum@suse.de>
	<2AC7D4AD8BA1C640B4C60C61C8E520153E3C13B620@EXDCVYMBSTM006.EQ1STM.local>
	<201106031250.28041.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey ORISHKO <alexey.orishko@stericsson.com>,
	"Valdis.Kletnieks\@vt.edu" <Valdis.Kletnieks@vt.edu>,
	Dan Williams <dcbw@redhat.com>,
	Stefan Metzmacher <metze@samba.org>,
	Oliver Neukum <oliver@neukum.name>,
	"Greg Kroah-Hartman" <gregkh@suse.de>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201106031250.28041.oneukum@suse.de> (Oliver Neukum's message of
	"Fri, 3 Jun 2011 12:50:27 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oneukum@suse.de> writes:

> Well, but cdc-ether usually means that you can start up dhcp and use =
the
> interface as a network card. Can the same be done with cdc-ncm or do =
you always
> need to establish a connection through a secondary interface?

Is there anything in the class definition that prevents either option,
for either protocol? No?

So, could we please kill the device guessing game?  Making decisions
based on absolute measures like "do we have a global mac address?" do
make some sense.  But guessing based on USB class does not.  That will
only tell you the protocol for the USB link. If you want more specific
device information, then you will have to look at the vid/pid. And I
assume you don't want to put all of those into the kernel when a class
driver will do, and whatever additional device specific information jus=
t
as well can be added by udev rules. Preferably created by whatever
application wishing to support the device.

But I do also assume you know all this already...



Bj=C3=B8rn
