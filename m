From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: Active URB submitted twice in pegasus driver
Date: Tue, 26 Mar 2013 22:54:25 +0200 (EET)
Message-ID: <alpine.DEB.2.02.1303262247490.3959@fry>
References: <20130325223834.GF6869@xanatos> <alpine.DEB.2.02.1303261655450.3724@fry.nucleusys.com> <20130326170140.GC10317@xanatos> <alpine.DEB.2.02.1303261909260.4226@fry.nucleusys.com> <20130326185218.GD10317@xanatos>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463750422-912820428-1364331274=:3959"
Cc: linux-usb@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:60345 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751459Ab3CZUyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 16:54:39 -0400
In-Reply-To: <20130326185218.GD10317@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463750422-912820428-1364331274=:3959
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed

On Tue, 26 Mar 2013, Sarah Sharp wrote:

> But considering the multicast code is pretty old, I bet I'm running into
> a different bug...

The fix is rather small.  Approximately one gigabyte was transferred while 
alternating in and out of promiscuous mode.  No issues.

I guess this should move the driver out of the equation.


cheers,
Petko
---1463750422-912820428-1364331274=:3959
Content-Type: TEXT/x-diff; name=pegasus.diff
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.DEB.2.02.1303262254250.3959@fry>
Content-Description: 
Content-Disposition: attachment; filename=pegasus.diff

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3VzYi9wZWdhc3VzLmMgYi9kcml2
ZXJzL25ldC91c2IvcGVnYXN1cy5jDQppbmRleCA3MzA1MWQxLi44NzlkYTM5
IDEwMDY0NA0KLS0tIGEvZHJpdmVycy9uZXQvdXNiL3BlZ2FzdXMuYw0KKysr
IGIvZHJpdmVycy9uZXQvdXNiL3BlZ2FzdXMuYw0KQEAgLTEyMjAsOCArMTIy
MCw2IEBAIHN0YXRpYyB2b2lkIHBlZ2FzdXNfc2V0X211bHRpY2FzdChzdHJ1
Y3QgbmV0X2RldmljZSAqbmV0KQ0KIAkJcGVnYXN1cy0+ZXRoX3JlZ3NbRXRo
Q3RybDJdICY9IH5SWF9QUk9NSVNDVU9VUzsNCiAJfQ0KIA0KLQlwZWdhc3Vz
LT5jdHJsX3VyYi0+c3RhdHVzID0gMDsNCi0NCiAJcGVnYXN1cy0+ZmxhZ3Mg
fD0gRVRIX1JFR1NfQ0hBTkdFOw0KIAljdHJsX2NhbGxiYWNrKHBlZ2FzdXMt
PmN0cmxfdXJiKTsNCiB9DQo=

---1463750422-912820428-1364331274=:3959--
