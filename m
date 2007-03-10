From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 1/4] [SOCKET]: Export __sock_recv_timestamp
Date: Sat, 10 Mar 2007 00:59:42 -0300
Message-ID: <39e6f6c70703091959k1f097529n3452692c3622a501@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_7667_9483462.1173499182754"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:23429 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965826AbXCJD7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 22:59:45 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1564210uga
        for <netdev@vger.kernel.org>; Fri, 09 Mar 2007 19:59:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_7667_9483462.1173499182754
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Kernel: arch/x86_64/boot/bzImage is ready  (#2)
  MODPOST 1816 modules
WARNING: "__sock_recv_timestamp" [net/sctp/sctp.ko] undefined!
WARNING: "__sock_recv_timestamp" [net/packet/af_packet.ko] undefined!
WARNING: "__sock_recv_timestamp" [net/key/af_key.ko] undefined!
WARNING: "__sock_recv_timestamp" [net/ipv6/ipv6.ko] undefined!
WARNING: "__sock_recv_timestamp" [net/atm/atm.ko] undefined!
make[2]: *** [__modpost] Error 1
make[1]: *** [modules] Error 2
make: *** [_all] Error 2

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/socket.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

------=_Part_7667_9483462.1173499182754
Content-Type: text/x-patch;
	name=0001-SOCKET-Export-__sock_recv_timestamp.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez3iwv77
Content-Disposition: attachment; filename="0001-SOCKET-Export-__sock_recv_timestamp.patch"

RnJvbSAyYTdmMzIwZThlNjRlNTZmNWNiN2ZkMDc2ZDk0M2Q3ODVmNTIyMjljIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU2F0LCAxMCBNYXIgMjAwNyAwMDozOTozNSAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMS80XSBbU09DS0VUXTogRXhwb3J0IF9fc29ja19yZWN2X3RpbWVzdGFtcAoKS2VybmVsOiBh
cmNoL3g4Nl82NC9ib290L2J6SW1hZ2UgaXMgcmVhZHkgICgjMikKICBNT0RQT1NUIDE4MTYgbW9k
dWxlcwpXQVJOSU5HOiAiX19zb2NrX3JlY3ZfdGltZXN0YW1wIiBbbmV0L3NjdHAvc2N0cC5rb10g
dW5kZWZpbmVkIQpXQVJOSU5HOiAiX19zb2NrX3JlY3ZfdGltZXN0YW1wIiBbbmV0L3BhY2tldC9h
Zl9wYWNrZXQua29dIHVuZGVmaW5lZCEKV0FSTklORzogIl9fc29ja19yZWN2X3RpbWVzdGFtcCIg
W25ldC9rZXkvYWZfa2V5LmtvXSB1bmRlZmluZWQhCldBUk5JTkc6ICJfX3NvY2tfcmVjdl90aW1l
c3RhbXAiIFtuZXQvaXB2Ni9pcHY2LmtvXSB1bmRlZmluZWQhCldBUk5JTkc6ICJfX3NvY2tfcmVj
dl90aW1lc3RhbXAiIFtuZXQvYXRtL2F0bS5rb10gdW5kZWZpbmVkIQptYWtlWzJdOiAqKiogW19f
bW9kcG9zdF0gRXJyb3IgMQptYWtlWzFdOiAqKiogW21vZHVsZXNdIEVycm9yIDIKbWFrZTogKioq
IFtfYWxsXSBFcnJvciAyCgpTaWduZWQtb2ZmLWJ5OiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8g
PGFjbWVAcmVkaGF0LmNvbT4KLS0tCiBuZXQvc29ja2V0LmMgfCAgICAyICsrCiAxIGZpbGVzIGNo
YW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9uZXQv
c29ja2V0LmMgYi9uZXQvc29ja2V0LmMKaW5kZXggOTk5NDMzMi4uZWVlYjc3MiAxMDA2NDQKLS0t
IGEvbmV0L3NvY2tldC5jCisrKyBiL25ldC9zb2NrZXQuYwpAQCAtNjE0LDYgKzYxNCw4IEBAIHZv
aWQgX19zb2NrX3JlY3ZfdGltZXN0YW1wKHN0cnVjdCBtc2doZHIgKm1zZywgc3RydWN0IHNvY2sg
KnNrLAogCX0KIH0KIAorRVhQT1JUX1NZTUJPTF9HUEwoX19zb2NrX3JlY3ZfdGltZXN0YW1wKTsK
Kwogc3RhdGljIGlubGluZSBpbnQgX19zb2NrX3JlY3Ztc2coc3RydWN0IGtpb2NiICppb2NiLCBz
dHJ1Y3Qgc29ja2V0ICpzb2NrLAogCQkJCSBzdHJ1Y3QgbXNnaGRyICptc2csIHNpemVfdCBzaXpl
LCBpbnQgZmxhZ3MpCiB7Ci0tIAoxLjUuMC4yCgo=
------=_Part_7667_9483462.1173499182754--
