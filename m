From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 08:03:09 -0400
Message-ID: <49D5FAFD.1010102@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D46089.5040204@redhat.com> <49D497A1.4090900@novell.com> <49D4A4EB.8020105@redhat.com> <49D4AE0C.3000604@novell.com> <49D4B2C0.5060906@redhat.com> <49D4B594.6080703@novell.com> <49D4B8B4.4020003@redhat.com> <49D4BF70.1060301@novell.com> <49D4C191.2070502@redhat.com> <49D4CAA7.3020004@novell.com> <49D4CC61.6010105@redhat.com> <49D4CEB1.9020001@redhat.com> <49D4D075.9010702@codemonkey.ws> <49D4E33F.5000303@codemonkey.ws>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig0554651CCD384529520C0DA3"
Cc: Avi Kivity <avi@redhat.com>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:38683 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754549AbZDCMAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2009 08:00:54 -0400
In-Reply-To: <49D4E33F.5000303@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig0554651CCD384529520C0DA3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Anthony Liguori wrote:
> Anthony Liguori wrote:
>> Avi Kivity wrote:
>>> Avi Kivity wrote:
>>>>
>>>> The alternative is to get a notification from the stack that the
>>>> packet is done processing.  Either an skb destructor in the kernel,
>>>> or my new API that everyone is not rushing out to implement.
>>>
>>> btw, my new api is
>>>
>>>
>>>   io_submit(..., nr, ...): submit nr packets
>>>   io_getevents(): complete nr packets
>>
>> I don't think we even need that to end this debate.  I'm convinced we
>> have a bug somewhere.  Even disabling TX mitigation, I see a ping
>> latency of around 300ns whereas it's only 50ns on the host.  This
>> defies logic so I'm now looking to isolate why that is.
>
> I'm down to 90us.  Obviously, s/ns/us/g above.  The exec.c changes
> were the big winner... I hate qemu sometimes.

[ Ive already said this privately to Anthony on IRC, but ..]

Hey, congrats!  Thats impressive actually.

So I realize that perhaps you guys are not quite seeing my long term
vision here, which I think will offer some new features that we dont
have today.  I hope to change that over the coming weeks.  However, I
should also point out that perhaps even if, as of right now, my one and
only working module (venet-tap) were all I could offer, it does give us
a "rivalry" position between the two, and this historically has been a
good thing on many projects.  This helps foster innovation through
competition that potentially benefits both.  Case in point, a little
competition provoked an investigation that brought virtio-net's latency
down from 3125us to 90us.  I realize its not a production-ready patch
quite yet, but I am confident Anthony will find something that is
suitable to checkin very soon.  That's a huge improvement to a problem
that was just sitting around unnoticed because there was nothing to
compare it with.

So again, I am proposing for consideration of accepting my work (either
in its current form, or something we agree on after the normal review
process) not only on the basis of the future development of the
platform, but also to keep current components in their running to their
full potential.  I will again point out that the code is almost
completely off to the side, can be completely disabled with config
options, and I will maintain it.  Therefore the only real impact is to
people who care to even try it, and to me.

-Greg


--------------enig0554651CCD384529520C0DA3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknV+v0ACgkQlOSOBdgZUxlS4ACdEsXeF969MC67HCpU4KG4Ke5G
ExsAn1KU921Mt5Oe1iF5xR+4aFkS225O
=pK7R
-----END PGP SIGNATURE-----

--------------enig0554651CCD384529520C0DA3--
