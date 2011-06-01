From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] usbnet/cdc_ncm: add missing .reset_resume hook
Date: Wed, 1 Jun 2011 11:43:46 +0200
Message-ID: <201106011143.46667.oneukum@suse.de>
References: <1306919630-13426-1-git-send-email-metze@samba.org> <1306919630-13426-2-git-send-email-metze@samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.name>,
	"Greg Kroah-Hartman" <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stefan Metzmacher <metze@samba.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306919630-13426-2-git-send-email-metze@samba.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 1. Juni 2011, 11:13:50 schrieb Stefan Metzmacher:
> This avoids messages like this after suspend:
>=20
>    cdc_ncm 2-1.4:1.6: no reset_resume for driver cdc_ncm?
>    cdc_ncm 2-1.4:1.7: no reset_resume for driver cdc_ncm?
>    cdc_ncm 2-1.4:1.6: usb0: unregister 'cdc_ncm' usb-0000:00:1d.0-1.4=
, CDC NCM
>=20
> This is important for the Ericsson F5521gw GSM/UMTS modem.
> Otherwise modemmanager looses the fact that the cdc_ncm and cdc_acm d=
evices
> belong together.
>=20
> The cdc_ether module does the same.

Yes, it does. Have you tested this with active connections and unconnec=
ted?

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
