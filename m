From: "Andrew Victor" <avictor.za@gmail.com>
Subject: [PATCH] AT91: Remove CRC on incoming frame
Date: Tue, 16 Sep 2008 22:43:55 +0200
Message-ID: <cd73a99e0809161343l7c46e083ufabd669c8a247e1d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_10546_22157940.1221597835861"
Cc: boris_astardzhiev@smartcom.bg
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.188]:17475 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbYIPUn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 16:43:58 -0400
Received: by rn-out-0910.google.com with SMTP id k40so1733067rnd.17
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 13:43:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_10546_22157940.1221597835861
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

In the Atmel AT91RM9200 Ethernet driver, remove the 4-byte CRC from
incoming frame before passing it to the upper layers.

Signed-off-by: Boris Astardzhiev <boris_astardzhiev@smartcom.bg>
Signed-off-by: Andrew Victor <linux@maxim.org.za>

------=_Part_10546_22157940.1221597835861
Content-Type: text/x-patch; name=6-ethernet_crc.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fl6zk4660
Content-Disposition: attachment; filename=6-ethernet_crc.patch

ZGlmZiAtdXJOIGxpbnV4LTIuNi4yNy1yYzYub3JpZy9kcml2ZXJzL25ldC9hcm0vYXQ5MV9ldGhl
ci5jIGxpbnV4LTIuNi4yNy1yYzYvZHJpdmVycy9uZXQvYXJtL2F0OTFfZXRoZXIuYwotLS0gbGlu
dXgtMi42LjI3LXJjNi5vcmlnL2RyaXZlcnMvbmV0L2FybS9hdDkxX2V0aGVyLmMJMjAwOC0wOS0x
NCAyMDoxNToyNy4wMDAwMDAwMDAgKzAyMDAKKysrIGxpbnV4LTIuNi4yNy1yYzYvZHJpdmVycy9u
ZXQvYXJtL2F0OTFfZXRoZXIuYwkyMDA4LTA5LTE2IDIxOjEwOjU1LjAwMDAwMDAwMCArMDIwMApA
QCAtODg4LDYgKzg4OCw3IEBACiAJd2hpbGUgKGRsaXN0LT5kZXNjcmlwdG9yc1tscC0+cnhCdWZm
SW5kZXhdLmFkZHIgJiBFTUFDX0RFU0NfRE9ORSkgewogCQlwX3JlY3YgPSBkbGlzdC0+cmVjdl9i
dWZbbHAtPnJ4QnVmZkluZGV4XTsKIAkJcGt0bGVuID0gZGxpc3QtPmRlc2NyaXB0b3JzW2xwLT5y
eEJ1ZmZJbmRleF0uc2l6ZSAmIDB4N2ZmOwkvKiBMZW5ndGggb2YgZnJhbWUgaW5jbHVkaW5nIEZD
UyAqLworCQlwa3RsZW4gPSBwa3RsZW4gLSA0OwkJLyogb21pdCA0LWJ5dGUgY2hlY2tzdW0gKi8K
IAkJc2tiID0gZGV2X2FsbG9jX3NrYihwa3RsZW4gKyAyKTsKIAkJaWYgKHNrYiAhPSBOVUxMKSB7
CiAJCQlza2JfcmVzZXJ2ZShza2IsIDIpOwo=
------=_Part_10546_22157940.1221597835861--
