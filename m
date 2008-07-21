From: Patrick McHardy <kaber@trash.net>
Subject: Re: drivers/s390/net/qeth_l3_main.c build error
Date: Mon, 21 Jul 2008 14:13:12 +0200
Message-ID: <48847D58.7050501@trash.net>
References: <20080721105553.GB22914@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040204070403000204060400"
Cc: Frank Blaschka <frank.blaschka@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35805 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbYGUMNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 08:13:50 -0400
In-Reply-To: <20080721105553.GB22914@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040204070403000204060400
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Adrian Bunk wrote:
> Commit 6aa895b047720f71ec4eb11452f7c3ce8426941f
> (vlan: Don't store VLAN tag in cb) causes the following build error:
>
> <--  snip  -->
>
> ...
>   CC      drivers/s390/net/qeth_l3_main.o
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_hard_start_xmit':
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c:2654: error: implicit declaration of function 'VLAN_TX_SKB_CB'
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c:2654: error: invalid type argument of '->' (have 'int')
> make[3]: *** [drivers/s390/net/qeth_l3_main.o] Error 1
>
> <--  snip  -->
>   

Sorry, this patch should fix it.



--------------040204070403000204060400
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="x"

cWV0aDogZml4IGJ1aWxkIGVycm9yIGNhdXNlZCBieSBWTEFOIGNoYW5nZXMKCkFkcmlhbiBC
dW5rIHJlcG9ydHMgdGhpcyBidWlsZCBlcnJvcjoKCkNDICAgICAgZHJpdmVycy9zMzkwL25l
dC9xZXRoX2wzX21haW4ubwovaG9tZS9idW5rL2xpbnV4L2tlcm5lbC0yLjYvZ2l0L2xpbnV4
LTIuNi9kcml2ZXJzL3MzOTAvbmV0L3FldGhfbDNfbWFpbi5jOiBJbiBmdW5jdGlvbiAncWV0
aF9sM19oYXJkX3N0YXJ0X3htaXQnOgovaG9tZS9idW5rL2xpbnV4L2tlcm5lbC0yLjYvZ2l0
L2xpbnV4LTIuNi9kcml2ZXJzL3MzOTAvbmV0L3FldGhfbDNfbWFpbi5jOjI2NTQ6IGVycm9y
OiBpbXBsaWNpdCBkZWNsYXJhdGlvbiBvZiBmdW5jdGlvbiAnVkxBTl9UWF9TS0JfQ0InCi9o
b21lL2J1bmsvbGludXgva2VybmVsLTIuNi9naXQvbGludXgtMi42L2RyaXZlcnMvczM5MC9u
ZXQvcWV0aF9sM19tYWluLmM6MjY1NDogZXJyb3I6IGludmFsaWQgdHlwZSBhcmd1bWVudCBv
ZiAnLT4nIChoYXZlICdpbnQnKQptYWtlWzNdOiAqKiogW2RyaXZlcnMvczM5MC9uZXQvcWV0
aF9sM19tYWluLm9dIEVycm9yIDEKClRoZSBpbnRlbnRpb24gb2YgdGhlIGRyaXZlciBhcHBl
YXJzIHRvIGJlIHRvIGludmFsaWRhdGUgdGhlIFZMQU4gdGFnLgpDaGFuZ2UgaXQgdG8gc2V0
IHNrYi0+dmxhbl90Y2kgdG8gemVybywgd2hpY2ggaGFzIHRoZSBzYW1lIGVmZmVjdC4KClNp
Z25lZC1vZmYtYnk6IFBhdHJpY2sgTWNIYXJkeSA8a2FiZXJAdHJhc2gubmV0PgpkaWZmIC0t
Z2l0IGEvZHJpdmVycy9zMzkwL25ldC9xZXRoX2wzX21haW4uYyBiL2RyaXZlcnMvczM5MC9u
ZXQvcWV0aF9sM19tYWluLmMKaW5kZXggYjI5YWZlZi4uMzhkZTMxYiAxMDA2NDQKLS0tIGEv
ZHJpdmVycy9zMzkwL25ldC9xZXRoX2wzX21haW4uYworKysgYi9kcml2ZXJzL3MzOTAvbmV0
L3FldGhfbDNfbWFpbi5jCkBAIC0yNjUxLDcgKzI2NTEsNyBAQCBzdGF0aWMgaW50IHFldGhf
bDNfaGFyZF9zdGFydF94bWl0KHN0cnVjdCBza19idWZmICpza2IsIHN0cnVjdCBuZXRfZGV2
aWNlICpkZXYpCiAJCQl0YWcgPSAodTE2ICopKG5ld19za2ItPmRhdGEgKyAxMik7CiAJCQkq
dGFnID0gX19jb25zdGFudF9odG9ucyhFVEhfUF84MDIxUSk7CiAJCQkqKHRhZyArIDEpID0g
aHRvbnModmxhbl90eF90YWdfZ2V0KG5ld19za2IpKTsKLQkJCVZMQU5fVFhfU0tCX0NCKG5l
d19za2IpLT5tYWdpYyA9IDA7CisJCQluZXdfc2tiLT52bGFuX3RjaSA9IDA7CiAJCX0KIAl9
CiAK
--------------040204070403000204060400--
