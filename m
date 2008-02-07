From: Robert Brockway <robert@timetraveller.org>
Subject: [PATCH] New device for DM9601 usb net driver
Date: Thu, 7 Feb 2008 11:00:33 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0802071046540.24824@castor.opentrend.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463807880-606225049-1202399624=:24824"
Cc: netdev@vger.kernel.org
To: jacmet@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.istop.com ([209.195.118.109]:53921 "EHLO ns.istop.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754891AbYBGQWu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 11:22:50 -0500
Content-ID: <Pine.LNX.4.64.0802071054290.24824@castor.opentrend.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463807880-606225049-1202399624=:24824
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; FORMAT=flowed
Content-ID: <Pine.LNX.4.64.0802071054291.24824@castor.opentrend.net>

Hi Peter.  I've verified that the Hirose USB-100 (0x0a47, 0x9601) is a 
clone of the DAVICOM DM9601.  I patched dm9601.c to identify this device 
and now have these in production.  Unified diff against 2.6.24 attached.

Cheers,

Rob

-- 
"With sufficient thrust, pigs fly just fine..."
 	-- RFC 1925 "The Twelve Networking Truths"
---1463807880-606225049-1202399624=:24824
Content-Type: TEXT/X-DIFF; CHARSET=US-ASCII; NAME=dm9601.c.diff
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.64.0802071053440.24824@castor.opentrend.net>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=dm9601.c.diff

LS0tIGRyaXZlcnMvbmV0L3VzYi9kbTk2MDEuYy5vbGQJMjAwOC0wMS0yNyAw
MDo1MTo1MC4wMDAwMDAwMDAgLTA1MDANCisrKyBkcml2ZXJzL25ldC91c2Iv
ZG05NjAxLmMJMjAwOC0wMi0wNyAxMDoyNzo0MC4wMDAwMDAwMDAgLTA1MDAN
CkBAIC01OTAsNiArNTkwLDEwIEBAIHN0YXRpYyBjb25zdCBzdHJ1Y3QgdXNi
X2RldmljZV9pZCBwcm9kdWMNCiAJIFVTQl9ERVZJQ0UoMHgwYTQ2LCAweDg1
MTUpLAkvKiBBRE10ZWsgQURNODUxNSBVU0IgTklDICovDQogCSAuZHJpdmVy
X2luZm8gPSAodW5zaWduZWQgbG9uZykmZG05NjAxX2luZm8sDQogCSB9LA0K
Kwl7DQorCVVTQl9ERVZJQ0UoMHgwYTQ3LCAweDk2MDEpLCAgICAvKiBIaXJv
c2UgVVNCLTEwMCAqLw0KKwkuZHJpdmVyX2luZm8gPSAodW5zaWduZWQgbG9u
ZykmZG05NjAxX2luZm8sDQorCX0sDQogCXt9LAkJCS8vIEVORA0KIH07DQog
DQo=

---1463807880-606225049-1202399624=:24824--
