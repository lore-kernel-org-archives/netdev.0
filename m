From: Fredi <fredin77@yahoo.com>
Subject: Re: iwl3945, after a while stops working with "No space for Tx"
Date: Mon, 26 Oct 2009 10:04:55 -0700 (PDT)
Message-ID: <776769.29896.qm@web53901.mail.re2.yahoo.com>
References: <1256574352.21134.7591.camel@rc-desk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YiZhu <yi.zhu@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	TomasWinkler <tomas.winkler@intel.com>,
	AbhijeetKolekar <abhijeet.kolekar@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: reinette chatre <reinette.chatre@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753859AbZJZREx@vger.kernel.org>
In-Reply-To: <1256574352.21134.7591.camel@rc-desk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
first thanks for your reply,
--- On Mon, 26/10/09, reinette chatre <reinette.chatre@intel.com> wrote=
:

> From: reinette chatre <reinette.chatre@intel.com>
> Subject: Re: iwl3945, after a while stops working with "No space for =
Tx"
> To: "Frederik Nosi" <fredin77@yahoo.com>
> Cc: "Zhu, Yi" <yi.zhu@intel.com>, "Intel Linux Wireless" <ilw@linux.i=
ntel.com>, "John W. Linville" <linville@tuxdriver.com>, "Winkler, Tomas=
" <tomas.winkler@intel.com>, "Kolekar, Abhijeet" <abhijeet.kolekar@inte=
l.com>, "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.or=
g>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vg=
er.kernel.org" <linux-kernel@vger.kernel.org>
> Date: Monday, 26 October, 2009, 5:25 PM
> On Sat, 2009-10-24 at 06:44 -0700,
> Frederik Nosi wrote:
> > Hi,
> > first sorry if somebody is not the right contact, got
> the adressess from ./scripts/get_maintainer.pl -f
> drivers/net/wireless/iwlwifi.
> > From some kernel versions now, after some time that im
> using this card it stops working and on messages i get this
> errors:
> >=20
> > Oct 24 14:38:24 kotys NetworkManager:
> <info>=A0 Activation (wlan0) Stage 5 of 5 (IP
> Configure Commit) complete.
> > [snip pulseaudio's stuppid log spam warning]
> > Oct 24 14:40:07 kotys kernel: iwl3945 0000:04:00.0:
> Error sending REPLY_TX_PWR_TABLE_CMD: time out after 500ms.
> > Oct 24 14:40:09 kotys pulseaudio[16469]: sap.c:
> sendmsg() failed: Invalid argument
> > Oct 24 14:40:10 kotys kernel: iwl3945 0000:04:00.0:
> Error sending REPLY_SCAN_CMD: time out after 500ms.
> > Oct 24 14:40:11 kotys kernel: iwl3945 0000:04:00.0:
> Error sending REPLY_TX_PWR_TABLE_CMD: time out after 500ms.
> > Oct 24 14:40:11 kotys kernel: iwl3945 0000:04:00.0:
> Error sending POWER_TABLE_CMD: time out after 500ms.
> > Oct 24 14:40:14 kotys kernel: iwl3945 0000:04:00.0:
> set power fail, ret =3D -110
> > Oct 24 14:40:14 kotys kernel: No probe response from
> AP 00:1c:df:82:63:c9 after 500ms, disconnecting.
> > Oct 24 14:40:14 kotys NetworkManager:
> <info>=A0 (wlan0): supplicant connection
> state:=A0 completed -> disconnected
> > Oct 24 14:40:14 kotys NetworkManager:
> <info>=A0 (wlan0): supplicant connection
> state:=A0 disconnected -> scanning
> > Oct 24 14:40:14 kotys pulseaudio[16469]: sap.c:
> sendmsg() failed: Invalid argument
> > Oct 24 14:40:14 kotys kernel: iwl3945 0000:04:00.0:
> Error sending REPLY_RXON: time out after 500ms.
> > Oct 24 14:40:14 kotys kernel: iwl3945 0000:04:00.0:
> Error setting new configuration (-110).
> > Oct 24 14:40:15 kotys kernel: iwl3945 0000:04:00.0:
> Error sending REPLY_SCAN_CMD: time out after 500ms.
> > Oct 24 14:40:15 kotys kernel: wlan0: direct probe to
> AP 00:1c:df:82:63:c9 (try 1)
> > Oct 24 14:40:15 kotys NetworkManager:
> <info>=A0 (wlan0): supplicant connection
> state:=A0 scanning -> associating
> > Oct 24 14:40:15 kotys kernel: wlan0: direct probe to
> AP 00:1c:df:82:63:c9 (try 2)
> > Oct 24 14:40:15 kotys kernel: wlan0: direct probe to
> AP 00:1c:df:82:63:c9 (try 3)
> > Oct 24 14:40:15 kotys kernel: iwl3945 0000:04:00.0:
> Error sending REPLY_RXON: time out after 500ms.
> > Oct 24 14:40:15 kotys kernel: iwl3945 0000:04:00.0:
> Error setting new configuration (-110).
> > Oct 24 14:40:15 kotys kernel: wlan0: direct probe to
> AP 00:1c:df:82:63:c9 timed out
> > Oct 24 14:40:16 kotys kernel: iwl3945 0000:04:00.0:
> Error sending REPLY_TX_PWR_TABLE_CMD: time out after 500ms.
> > Oct 24 14:40:16 kotys kernel: iwl3945 0000:04:00.0:
> Error sending REPLY_RXON: time out after 500ms.
> > Oct 24 14:40:16 kotys kernel: iwl3945 0000:04:00.0:
> Error setting new configuration (-110).
> >=20
> >=20
> > When this happens i am able to use the card only after
> reloading the related modules, iwl3945 ecc. But the problem
> happens again after some minutes that im connected.
> >=20
> > Kernel is 2.6.32-rc5 but his started happening around
> 2.6.31, not sure exactly what version as i update kernel
> often. Firmware is iwl3945-ucode-15.32.2.9.
> >=20
> > Every other info that you need just ask. I hope i dont
> have to bisect as this is the laptop i use for work too, but
> if it's needed i'll do.
> >=20
> > I'm not subscribed on any ML, so in case please cc
> me.
> >=20
>=20
> We currently have a bug open for this issue. Could you
> please add this
>
> information to
> http://bugzilla.intellinuxwireless.org/show_bug.cgi?id=3D1944
> ?

Done, noticed that there's a patch for this issue. Will try and tell th=
e results. And noticed the link on how to report possible firmware prob=
lems, will follow that procedure and post the results of that too.
=20
> Thank you

Thaks for pointing me on the right direction!

> Reinette
>=20
>=20

=46rederik


     =20
