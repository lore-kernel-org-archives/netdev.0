From: Yavor Goulishev <yavor@simplifymedia.com>
Subject: Patch - Establishing more than 64K outgoing TCP connections
Date: Tue, 28 Oct 2008 14:51:00 -0400
Message-ID: <241CE5A1B2AFFA4987A663380D74C0BB3FD69B0830@MBX73.ad2.softcom.biz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_241CE5A1B2AFFA4987A663380D74C0BB3FD69B0830MBX73ad2softc_"
Cc: David Miller <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xsmtp06.mail2web.com ([168.144.250.246]:35560 "EHLO
	xsmtp06.mail2web.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957AbYJ1Wz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 18:55:56 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_241CE5A1B2AFFA4987A663380D74C0BB3FD69B0830MBX73ad2softc_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi guys,
I'm sending you a tiny patch for the kernel.
The change allowed me to establish more than 64K outgoing TCP connections f=
rom a single Linux box.
Being able to use multihomed client box to load test a server reduced drama=
tically the number of physical boxes I needed.
The other way to go was virtual machines, but you can't beat the simplicity=
 of the single multihomed client.
Also the patch fixes an important symmetry.
Using the multihome setup is a simple technique to overcome the 64K limit o=
n the server side.
The patch makes it possible on the client side too.

The fix is only for TCP but probably the same issue exists for UDP.
I didn't had the time to investigate.

The patch is against the latest code base 2.6.28-rc2.

--Yavor



--_002_241CE5A1B2AFFA4987A663380D74C0BB3FD69B0830MBX73ad2softc_
Content-Type: text/x-diff; name="patch.diff"
Content-Description: patch.diff
Content-Disposition: attachment; filename="patch.diff"; size=582;
	creation-date="Tue, 28 Oct 2008 00:32:18 GMT";
	modification-date="Tue, 28 Oct 2008 00:32:18 GMT"
Content-Transfer-Encoding: base64

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L2luZXRfY29ubmVjdGlvbl9zb2NrLmMgYi9uZXQvaXB2NC9p
bmV0X2Nvbm5lY3Rpb25fc29jay5jCmluZGV4IGJkMTI3OGEuLmQ3MmZiYTYgMTAwNjQ0Ci0tLSBh
L25ldC9pcHY0L2luZXRfY29ubmVjdGlvbl9zb2NrLmMKKysrIGIvbmV0L2lwdjQvaW5ldF9jb25u
ZWN0aW9uX3NvY2suYwpAQCAtMTA5LDcgKzEwOSw5IEBAIGludCBpbmV0X2Nza19nZXRfcG9ydChz
dHJ1Y3Qgc29jayAqc2ssIHVuc2lnbmVkIHNob3J0IHNudW0pCiAJCQkJCWhhc2hpbmZvLT5iaGFz
aF9zaXplKV07CiAJCQlzcGluX2xvY2soJmhlYWQtPmxvY2spOwogCQkJaW5ldF9iaW5kX2J1Y2tl
dF9mb3JfZWFjaCh0Yiwgbm9kZSwgJmhlYWQtPmNoYWluKQotCQkJCWlmICh0Yi0+aWJfbmV0ID09
IG5ldCAmJiB0Yi0+cG9ydCA9PSByb3ZlcikKKwkJCQlpZiAodGItPmliX25ldCA9PSBuZXQgJiYK
KwkJCQkgICAgdGItPnBvcnQgPT0gcm92ZXIgJiYKKwkJCQkgICAgaW5ldF9jc2soc2spLT5pY3Nr
X2FmX29wcy0+YmluZF9jb25mbGljdChzaywgdGIpKQogCQkJCQlnb3RvIG5leHQ7CiAJCQlicmVh
azsKIAkJbmV4dDoK

--_002_241CE5A1B2AFFA4987A663380D74C0BB3FD69B0830MBX73ad2softc_--
