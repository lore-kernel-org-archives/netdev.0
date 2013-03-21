From: James Harper <james.harper@bendigoit.com.au>
Subject: RE: [Xen-devel] [PATCH 4/4] xen-netback: coalesce slots before
 copying
Date: Thu, 21 Mar 2013 22:14:17 +0000
Message-ID: <6035A0D088A63A46850C3988ED045A4B387FB199@BITCOM1.int.sbss.com.au>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
 <1363602955-24790-5-git-send-email-wei.liu2@citrix.com>
 <6035A0D088A63A46850C3988ED045A4B387EC758@BITCOM1.int.sbss.com.au>
 <6035A0D088A63A46850C3988ED045A4B387EC8DC@BITCOM1.int.sbss.com.au>
 <CAOsiSVWSRmo1+Ubo7GyAKcvUr8XUenkMvnAqt607gPoJm-sXFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <liuw@liuw.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.bendigoit.com.au ([203.16.224.4]:59171 "EHLO
	smtp1.bendigoit.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137Ab3CUWOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 18:14:54 -0400
In-Reply-To: <CAOsiSVWSRmo1+Ubo7GyAKcvUr8XUenkMvnAqt607gPoJm-sXFQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiANCj4+IEFjdHVhbGx5IGl0IHR1cm5zIG91dCBHUExQViBqdXN0IHN0b3BzIGNvdW50aW5nIGF0
IDIwLiBJZiBJIGtlZXANCj4+IGNvdW50aW5nIEkgY2FuIHNvbWV0aW1lcyBzZWUgb3ZlciAxMDAw
IGJ1ZmZlcnMgcGVyIEdTTyBwYWNrZXQgdW5kZXINCj4+IFdpbmRvd3MgdXNpbmcgImlwZXJmIC0N
Cj4gDQo+IERvIHlvdSB0aGluayBpdCBpcyBuZWNlc3NhcnkgdG8gaW5jcmVhc2UgTUFYX1NLQl9T
TE9UU19ERUZBVUxUIHRvIDIxPw0KPiANCg0KRG9lc24ndCByZWFsbHkgbWF0dGVyLiBVbmRlciB3
aW5kb3dzIHlvdSBoYXZlIHRvIGNvYWxlc2NlIGFueXdheSBhbmQgdGhlIG51bWJlciBvZiBjYXNl
cyB3aGVyZSB0aGUgc2tiIGNvdW50IGlzIDIwIG9yIDIxIGlzIHZlcnkgc21hbGwgc28gdGhlcmUg
d2lsbCBiZSBuZWdsaWdpYmxlIGdhaW4gYW5kIGl0IHdpbGwgYnJlYWsgZ3Vlc3RzIHRoYXQgY2Fu
J3QgaGFuZGxlIG1vcmUgdGhhbiAxOS4NCg0KSGFzIGFueW9uZSBkb25lIHRoZSBiZW5jaG1hcmtz
IG9uIGlmIG1lbWNweSB0byBjb2FsZXNjZSBpcyBiZXR0ZXIgb3Igd29yc2UgdGhhbiBjb25zdW1p
bmcgYWRkaXRpb25hbCByaW5nIHNsb3RzPyBQcm9iYWJseSBPVCBoZXJlIGJ1dCBJJ20gdGFsa2lu
ZyBhYm91dCBwYWNrZXRzIHRoYXQgbWlnaHQgaGF2ZSAxOSBidWZmZXJzIGJ1dCBjb3VsZCBmaXQg
b24gYSBwYWdlIG9yIHR3byBvZiBjb2FsZXNjZWQuDQoNCkphbWVzDQoNCg==
