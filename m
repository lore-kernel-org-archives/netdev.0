From: "Stefan (metze) Metzmacher" <metze@samba.org>
Subject: Re: [PATCH] usbnet/cdc_ncm: add missing .reset_resume hook
Date: Tue, 07 Jun 2011 19:07:58 +0200
Message-ID: <4DEE5AEE.8070901@samba.org>
References: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E568@EXDCVYMBSTM006.EQ1STM.local> <1306929701-22861-1-git-send-email-metze@samba.org> <1306929701-22861-2-git-send-email-metze@samba.org> <20110601.211142.557328157396419857.davem@davemloft.net> <4DECC6B4.5020108@samba.org> <20110606150655.GB3732@suse.de> <4DEDD564.7050308@samba.org> <20110607144348.GB19246@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig66E2683F29591A504CE31BA7"
Cc: David Miller <davem@davemloft.net>, oliver@neukum.name,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110607144348.GB19246@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig66E2683F29591A504CE31BA7
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 07.06.2011 16:43, schrieb Greg KH:
> On Tue, Jun 07, 2011 at 09:38:12AM +0200, Stefan (metze) Metzmacher wro=
te:
>> Am 06.06.2011 17:06, schrieb Greg KH:
>>> On Mon, Jun 06, 2011 at 02:23:16PM +0200, Stefan (metze) Metzmacher w=
rote:
>>>> Hi David,
>>>>
>>>>> From: Stefan Metzmacher <metze@samba.org>
>>>>> Date: Wed,  1 Jun 2011 14:01:41 +0200
>>>>>
>>>>>> This avoids messages like this after suspend:
>>>>>>
>>>>>>    cdc_ncm 2-1.4:1.6: no reset_resume for driver cdc_ncm?
>>>>>>    cdc_ncm 2-1.4:1.7: no reset_resume for driver cdc_ncm?
>>>>>>    cdc_ncm 2-1.4:1.6: usb0: unregister 'cdc_ncm' usb-0000:00:1d.0-=
1.4, CDC NCM
>>>>>>
>>>>>> This is important for the Ericsson F5521gw GSM/UMTS modem.
>>>>>> Otherwise modemmanager looses the fact that the cdc_ncm and cdc_ac=
m devices
>>>>>> belong together.
>>>>>>
>>>>>> The cdc_ether module does the same.
>>>>>>
>>>>>> Signed-off-by: Stefan Metzmacher <metze@samba.org>
>>>>>
>>>>> Applied and queued up for -stable, thanks.
>>>>
>>>> It seems to be part of 3.0-rc2, but I'm not seeing it in any stable =
tree
>>>> yet...
>>>>
>>>> When can I expect it in stable trees like 2.6.38.y?
>>>
>>> The .38.y tree is closed and will not have new releases, so you will
>>> never see it there, sorry.
>>
>> Ok, are there chances for .39.y?
>=20
> There are, it requires the patch to be in Linus's tree first,

It's already there:

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dco=
mmitdiff;h=3D85e3c65fa3a1d0542c181510a950a2be7733ff29

> please see Documentation/stable_kernel_rules.txt for the details.

Thanks for the pointer. It seems I've missed the Cc: <stable@kernel.org>
line(s).

Would this be the correct syntax in order to get it into 2.6.38.x and
2.6.39.x?
(2.6.38 wasn't closed at the time I submitted the patch)

Cc: <stable@kernel.org> # .38.x
Cc: <stable@kernel.org> # .39.x

Should I resubmit the patch, or can you just cherry pick
85e3c65fa3a1d0542c181510a950a2be7733ff29
from Linus's tree?

metze


--------------enig66E2683F29591A504CE31BA7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk3uWu4ACgkQm70gjA5TCD/LHwCgqm3MlghKro9RVV83WwScvWmP
XTsAninON6umtcUw8U9QiPLRuJ6/x67M
=NvDw
-----END PGP SIGNATURE-----

--------------enig66E2683F29591A504CE31BA7--
