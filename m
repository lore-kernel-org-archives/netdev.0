From: Marian Corcodel <corcodel.marian@gmail.com>
Subject: [net-next]Disable writting on reg config1 value is read-only
Date: Wed, 8 Jul 2015 21:55:49 +0300
Message-ID: <CAGg4U=GvLSYKU8nrNq9VmEyS1jZ9ZUtrVo-KMzR1Nd-ULVKMvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=089e011609fceed3a9051a61afba
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:35151 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749AbbGHSzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 14:55:49 -0400
Received: by iecuq6 with SMTP id uq6so161961497iec.2
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 11:55:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--089e011609fceed3a9051a61afba
Content-Type: text/plain; charset=UTF-8

On rtl8101/8102 MEMMAP | IOMAP | VPD | PMEnable is enabled on default
and is read-only  and is not need to write on these.

--089e011609fceed3a9051a61afba
Content-Type: text/x-patch; charset=US-ASCII; name="disable_writing_ro_reg.patch"
Content-Disposition: attachment; filename="disable_writing_ro_reg.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ibv4lh1l0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L3JlYWx0ZWsvcjgxNjkuYyBiL2RyaXZl
cnMvbmV0L2V0aGVybmV0L3JlYWx0ZWsvcjgxNjkuYwppbmRleCAxYTU1MDU3Li5jMjg1MDI4IDEw
MDY0NAotLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9yZWFsdGVrL3I4MTY5LmMKKysrIGIvZHJp
dmVycy9uZXQvZXRoZXJuZXQvcmVhbHRlay9yODE2OS5jCkBAIC02NDE3LDcgKzY0MTcsNyBAQCBz
dGF0aWMgdm9pZCBydGxfaHdfc3RhcnRfODEwMmVfMihzdHJ1Y3QgcnRsODE2OV9wcml2YXRlICp0
cCkKIAogCXJ0bF90eF9wZXJmb3JtYW5jZV90d2VhayhwZGV2LCAweDUgPDwgTUFYX1JFQURfUkVR
VUVTVF9TSElGVCk7CiAKLQlSVExfVzgoQ29uZmlnMSwgTUVNTUFQIHwgSU9NQVAgfCBWUEQgfCBQ
TUVuYWJsZSk7CisJLy9SVExfVzgoQ29uZmlnMSwgTUVNTUFQIHwgSU9NQVAgfCBWUEQgfCBQTUVu
YWJsZSk7CiAJUlRMX1c4KENvbmZpZzMsIFJUTF9SOChDb25maWczKSAmIH5CZWFjb25fZW4pOwog
fQogCg==
--089e011609fceed3a9051a61afba--
