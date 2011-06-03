From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] TODO FLAG_POINTTOPOINT => FLAG_WWAN? usbnet/cdc_ncm: mark ncm devices as "mobile broadband devices" with FLAG_WWAN
Date: Fri, 3 Jun 2011 12:50:27 +0200
Message-ID: <201106031250.28041.oneukum@suse.de>
References: <1306922913-17803-1-git-send-email-metze@samba.org> <201106031201.21933.oneukum@suse.de> <2AC7D4AD8BA1C640B4C60C61C8E520153E3C13B620@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>,
	Dan Williams <dcbw@redhat.com>,
	Stefan Metzmacher <metze@samba.org>,
	Oliver Neukum <oliver@neukum.name>,
	"Greg Kroah-Hartman" <gregkh@suse.de>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexey ORISHKO <alexey.orishko@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C13B620@EXDCVYMBSTM006.EQ1STM.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, 3. Juni 2011, 12:23:21 schrieb Alexey ORISHKO:

> There is no difference between cdc_ncm and cdc_ether devices, besides
> the fact cdc_ncm is more efficient in data transfer and cpu load.
> The problem is that you cannot say much about device functionality ba=
sed
> just on interface name. As example existing devices with cdc_ether=20
> interface could be mobile phone which provides connectivity to 3G net=
work,
> or could be a phone in the mode "over PC", where phone applications
> access internet via broadband connection on PC (to save money).
>=20
> Network manager cannot simply make decision which devices can be used
> for mobile broadband access based on interface name. It needs an addi=
tional
> info, which does not exist in device descriptor.=20

Well, but cdc-ether usually means that you can start up dhcp and use th=
e
interface as a network card. Can the same be done with cdc-ncm or do yo=
u always
need to establish a connection through a secondary interface?

	Regards
		Oliver
--=20
- - -=20
SUSE LINUX Products GmbH, GF: Jeff Hawn, Jennifer Guild, Felix Imend=F6=
rffer, HRB 16746 (AG N=FCrnberg)=20
Maxfeldstra=DFe 5                        =20
90409 N=FCrnberg=20
Germany=20
- - -=20
