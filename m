From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 13/17] x86: allow the irq->vector translation to be
 determined outside of ioapic
Date: Tue, 31 Mar 2009 16:02:15 -0400
Message-ID: <49D276C7.80600@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net>	<20090331184355.28333.72382.stgit@dev.haskins.net> <20090331201625.60f1ea81@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigFD773E1CA8A872ED2EDE7070"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:59808 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbZCaT76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 15:59:58 -0400
In-Reply-To: <20090331201625.60f1ea81@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigFD773E1CA8A872ED2EDE7070
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Alan Cox wrote:
> On Tue, 31 Mar 2009 14:43:55 -0400
> Gregory Haskins <ghaskins@novell.com> wrote:
>
>  =20
>> The ioapic code currently privately manages the mapping between irq
>> and vector.  This results in some layering violations as the support
>> for certain MSI operations need this info.  As a result, the MSI
>> code itself was moved to the ioapic module.  This is not really
>> optimal.
>>    =20
>
> This appears to have been muddled in with the vnet patches ?
>  =20
Its needed for the kvm-connector patches later in the series, so it was
included intentionally.

On that topic, I probably should have had a TOC of some kind.  Hmm..let
me hack one together now:

Patch 1: Stand-alone "shared-memory signal" construct, used by various
components in vbus/venet
Patches 2-5: Basic vbus infrastructure
Patches 6-7: IOQ construct, similar to virtio-ring.  Used to overlay
ring-like behavior over the shm interface in vbus
Patches 8-12: virtual-ethernet front and backends
Patch 13: io-apic work to expose the irq-vector in x86, needed for
dynirq support
Patches 14-16: KVM host side support
Patch 17: KVM guest side support

Sorry for the confusion :(

Regards,
-Greg


--------------enigFD773E1CA8A872ED2EDE7070
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknSdscACgkQlOSOBdgZUxl01ACfSEnYOhxGIU+EHpUI0oDIUmII
BfsAn277JrlDG6dO2eSy2gQji78cpbaE
=rI1L
-----END PGP SIGNATURE-----

--------------enigFD773E1CA8A872ED2EDE7070--
