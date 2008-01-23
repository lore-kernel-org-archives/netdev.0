From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [PKTGEN] Remove an unused definition in pktgen.c.
Date: Wed, 23 Jan 2008 16:38:09 +0200
Message-ID: <eb3ff54b0801230638j4e0ece76sf0a2592477050fee@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_6660_17493707.1201099089370"
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:25588 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754967AbYAWOiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 09:38:11 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2253145fga.17
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 06:38:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_6660_17493707.1201099089370
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
- Remove an unused definition (LAT_BUCKETS_MAX) in net/core/pktgen.c.
- Remove the corresponding comment.
- The LAT_BUCKETS_MAX seems to have to do with a patch from a long
time ago which was not applied (Ben Greear), which dealt with latency
counters.

See, for example : http://oss.sgi.com/archives/netdev/2002-09/msg00184.html

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_6660_17493707.1201099089370
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fbrz731j0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL3BrdGdlbi5jIGIvbmV0L2NvcmUvcGt0Z2VuLmMKaW5kZXgg
ZWViY2NkYi4uYjdmMmRlMSAxMDA2NDQKLS0tIGEvbmV0L2NvcmUvcGt0Z2VuLmMKKysrIGIvbmV0
L2NvcmUvcGt0Z2VuLmMKQEAgLTE3MCw4ICsxNzAsNiBAQAogCiAjZGVmaW5lIFZFUlNJT04gICJw
a3RnZW4gdjIuNjk6IFBhY2tldCBHZW5lcmF0b3IgZm9yIHBhY2tldCBwZXJmb3JtYW5jZSB0ZXN0
aW5nLlxuIgogCi0vKiBUaGUgYnVja2V0cyBhcmUgZXhwb25lbnRpYWwgaW4gJ3dpZHRoJyAqLwot
I2RlZmluZSBMQVRfQlVDS0VUU19NQVggMzIKICNkZWZpbmUgSVBfTkFNRV9TWiAzMgogI2RlZmlu
ZSBNQVhfTVBMU19MQUJFTFMgMTYgLyogVGhpcyBpcyB0aGUgbWF4IGxhYmVsIHN0YWNrIGRlcHRo
ICovCiAjZGVmaW5lIE1QTFNfU1RBQ0tfQk9UVE9NIGh0b25sKDB4MDAwMDAxMDApCg==
------=_Part_6660_17493707.1201099089370--
