From: "Harsha R02" <Harsha.R02@mphasis.com>
Subject: RE: [Bugme-new] [Bug 29712] New: Bonding Driver(version : 3.5.0) - Problem with ARP monitoring in active backup mode
Date: Fri, 25 Feb 2011 18:14:32 +0530
Message-ID: <E351E450E8B9F54684A699D42DC5ADF210062FA2@MPBAGVEX02.corp.mphasis.com>
References: <bug-29712-10286@https.bugzilla.kernel.org/> <20110224145129.f366b59e.akpm@linux-foundation.org> <4D672525.5080609@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01CBD4E9.E1D9D260"
Cc: <bugzilla-daemon@bugzilla.kernel.org>,
	<bugme-daemon@bugzilla.kernel.org>, <netdev@vger.kernel.org>,
	"Jay Vosburgh" <fubar@us.ibm.com>
To: "Brian Haley" <brian.haley@hp.com>,
	"Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vx.mphasis.com ([203.12.223.66]:4059 "EHLO
	mpbam6ip2.mphasis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753792Ab1BYNza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 08:55:30 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4D672525.5080609@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

------_=_NextPart_001_01CBD4E9.E1D9D260
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Attached patch resolves the issue. Failover happened back to primary
when it was up again in both the point to point and switch
configuration.

Please let us know if this change can be included.

Thanks,

- Harsha


-----Original Message-----
From: Brian Haley [mailto:brian.haley@hp.com]=20
Sent: Friday, February 25, 2011 9:12 AM
To: Andrew Morton
Cc: Harsha R02; bugzilla-daemon@bugzilla.kernel.org;
bugme-daemon@bugzilla.kernel.org; netdev@vger.kernel.org; Jay Vosburgh
Subject: Re: [Bugme-new] [Bug 29712] New: Bonding Driver(version :
3.5.0) - Problem with ARP monitoring in active backup mode

On 02/24/2011 05:51 PM, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via
the
> bugzilla web interface).
>=20
> On Wed, 23 Feb 2011 10:41:34 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>=20
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D29712
>>
>>            Summary: Bonding Driver(version : 3.5.0) - Problem with
ARP
>>                     monitoring in active backup mode
>>            Product: Drivers
>>            Version: 2.5
>>     Kernel Version: 2.6.32
>=20
> That's a paleolithic kernel you have there.  This problem might have
> been fixed already.  Can you test a more recent kernel?

I can add some more info since I originally looked at the problem.  This
happens on 2.6.38 as well, and on this 2.6.32 kernel with a backported
3.7.0 bonding driver (with the primary_reselect option).  Harsha has a
prototype patch that's being tested, but wanted to log the bug to see
if one of the bonding maintainers had a better solution.

I'll let him respond as I'm now out of the loop...

Thanks,

-Brian

Information transmitted by this e-mail is proprietary to MphasiS, its assoc=
iated companies and/ or its customers and is intended=20
for use only by the individual or entity to which it is addressed, and may =
contain information that is privileged, confidential or=20
exempt from disclosure under applicable law. If you are not the intended re=
cipient or it appears that this mail has been forwarded=20
to you without proper authority, you are notified that any use or dissemina=
tion of this information in any manner is strictly=20
prohibited. In such cases, please notify us immediately at mailmaster@mphas=
is.com and delete this mail from your records.

------_=_NextPart_001_01CBD4E9.E1D9D260
Content-Type: application/octet-stream;
	name="bonding.patch"
Content-Transfer-Encoding: base64
Content-Description: bonding.patch
Content-Disposition: attachment;
	filename="bonding.patch"

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2JvbmRpbmcvYm9uZF9tYWluLmMgYi9kcml2ZXJzL25l
dC9ib25kaW5nL2JvbmRfbWFpbi5jDQppbmRleCA0MGZiNWVlLi4wNDEzOTE3IDEwMDY0NA0KLS0t
IGEvZHJpdmVycy9uZXQvYm9uZGluZy9ib25kX21haW4uYw0KKysrIGIvZHJpdmVycy9uZXQvYm9u
ZGluZy9ib25kX21haW4uYw0KQEAgLTMwMjAsMTEgKzMwMjAsMTYgQEAgc3RhdGljIHZvaWQgYm9u
ZF9hYl9hcnBfcHJvYmUoc3RydWN0IGJvbmRpbmcgKmJvbmQpDQogICAgICAgICAgICAgICAgICAg
ICAgIGJvbmQtPmN1cnJfYWN0aXZlX3NsYXZlLT5kZXYtPm5hbWUpOw0KDQogICAgICAgIGlmIChi
b25kLT5jdXJyX2FjdGl2ZV9zbGF2ZSkgew0KKyAgICAgICAgICAgICAgICBpZigoYm9uZC0+Y3Vy
cl9hY3RpdmVfc2xhdmUgIT0gYm9uZC0+cHJpbWFyeV9zbGF2ZSkgJiYNCisgICAgICAgICAgICAg
ICAgICAgKElTX1VQKGJvbmQtPnByaW1hcnlfc2xhdmUtPmRldikpKQ0KKyAgICAgICAgICAgICAg
ICAgICAgICAgIGdvdG8gZmFpbG92ZXI7DQorDQogICAgICAgICAgICAgICAgYm9uZF9hcnBfc2Vu
ZF9hbGwoYm9uZCwgYm9uZC0+Y3Vycl9hY3RpdmVfc2xhdmUpOw0KICAgICAgICAgICAgICAgIHJl
YWRfdW5sb2NrKCZib25kLT5jdXJyX3NsYXZlX2xvY2spOw0KICAgICAgICAgICAgICAgIHJldHVy
bjsNCiAgICAgICAgfQ0KDQorZmFpbG92ZXI6DQogICAgICAgIHJlYWRfdW5sb2NrKCZib25kLT5j
dXJyX3NsYXZlX2xvY2spOw0KDQogICAgICAgIC8qIGlmIHdlIGRvbid0IGhhdmUgYSBjdXJyX2Fj
dGl2ZV9zbGF2ZSwgc2VhcmNoIGZvciB0aGUgbmV4dCBhdmFpbGFibGUNCg==

------_=_NextPart_001_01CBD4E9.E1D9D260--

