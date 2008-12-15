From: <Narendra_K@Dell.com>
Subject: [PATCH]-bonding: Fix slave link failure count update failure
Date: Mon, 15 Dec 2008 19:52:54 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE511805@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01C95EC0.9ECA6113"
Cc: <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:49817 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755866AbYLOOXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 09:23:16 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

------_=_NextPart_001_01C95EC0.9ECA6113
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable


Hello,

The "bonding: refactor mii monitor" patch (
http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.27.y.git;a=3D=
co
mmit;h=3Df0c76d61779b153dbfb955db3f144c62d02173c2) misses updating the
slave link failure count. So "cat /proc/net/bonding/bond0" doesn't
reflect the no of slave link failures. The patch addresses it.

Signed-off-by: Narendra K <narendra_k@dell.com>

With regards,
Narendra K

------_=_NextPart_001_01C95EC0.9ECA6113
Content-Type: application/octet-stream;
	name="bond_slave_link_failure_count.patch"
Content-Transfer-Encoding: base64
Content-Description: bond_slave_link_failure_count.patch
Content-Disposition: attachment;
	filename="bond_slave_link_failure_count.patch"

LS0tIGxpbnV4LTIuNi4yNy45L2RyaXZlcnMvbmV0L2JvbmRpbmcvYm9uZF9tYWluLmMJMjAwOC0x
Mi0xNCAwNToyNjoxNi4wMDAwMDAwMDAgKzA1MzAKKysrIGxpbnV4LTIuNi4yNy45LW5ldy9kcml2
ZXJzL25ldC9ib25kaW5nL2JvbmRfbWFpbi5jCTIwMDgtMTItMTUgMTk6MDY6NDguMDAwMDAwMDAw
ICswNTMwCkBAIC0yMjQxLDYgKzIyNDEsMTEgQEAKIAogCQkJc2xhdmUtPmxpbmsgPSBCT05EX0xJ
TktfRkFJTDsKIAkJCXNsYXZlLT5kZWxheSA9IGJvbmQtPnBhcmFtcy5kb3duZGVsYXk7CisKKwkJ
CWlmIChzbGF2ZS0+bGlua19mYWlsdXJlX2NvdW50IDwgVUlOVF9NQVgpIHsKKwkJCQlzbGF2ZS0+
bGlua19mYWlsdXJlX2NvdW50Kys7CisJCQl9CisKIAkJCWlmIChzbGF2ZS0+ZGVsYXkpIHsKIAkJ
CQlwcmludGsoS0VSTl9JTkZPIERSVl9OQU1FCiAJCQkJICAgICAgICI6ICVzOiBsaW5rIHN0YXR1
cyBkb3duIGZvciAlcyIK

------_=_NextPart_001_01C95EC0.9ECA6113--
