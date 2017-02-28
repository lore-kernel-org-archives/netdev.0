From: =?GBK?B?0dXQobKo?= <yanxb123@163.com>
Subject: [drivers/net/vxlan]Why rcu_read_lock is not obtained before rculist
 travelling
Date: Tue, 28 Feb 2017 22:03:48 +0800 (CST)
Message-ID: <199cc09e.de3a.15a8508c1f7.Coremail.yanxb123@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: "Stephen Hemminger" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m13-98.163.com ([220.181.13.98]:36611 "EHLO m13-98.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751060AbdB1OTD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 09:19:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgU3RlcGhlbiwKCgpJIGFtIHN0dWR5aW5nIHZ4bGFuIGRldmljZSBkcml2ZXIgaW4gNC4xMCBr
ZXJuZWwuIEkgc2VlIHRoYXQgdnhsYW5fZmRiIGluIGZkYl9oZWFkIGxpc3QgaXMgcmN1IHByb3Rl
Y3RlZC4gY2FsbF9yY3UgaXMgaW52b2tlZCB0byBmcmVlIHZ4bGFuIGZkYiwgd2hpY2ggd2lsbCBk
ZWZlciB0aGUgdnhsYW5fZmRiX2ZyZWUgdW50aWwgYWxsIHJjdSByZWFkcyBleGlzdCB0aGUgcmFj
ZSBjb25kaXRpb24uIAoKQnV0IEkgZG9uoa90IGZpbmQgYW55IHJjdV9yZWFkX2xvY2sgaW52b2tl
ZCBiZWZvcmUgdHJhdmVsbGluZyBmZGJfaGVhZCBsaXN0LiAgSW4gdnhsYW5feG1pdCBhbmQgdnhs
YW5fc25vb3AgZnVuY3Rpb24sIHZ4bGFuX2ZpbmRfbWFjIGZ1bmN0aW9uIGlzIGNhbGxlZCB0byBz
ZWFyY2ggdGhlIHZ4bGFuX2ZkYiBvZiB0aGUgZHN0X21hYyBvciBzcmNfbWFjLiBUaGVuIGluZm9y
bWF0aW9uIGluIHZ4bGFuX2ZkYiAgaXMgdXNlZCBmb3IgZnVydGhlciBwcm9jZXNzLiAgQnV0IGFz
IG5vIHJjdV9yZWFkX2xvY2sgaXMgb2J0YWluZWQgYmVmb3JlIHRoZSBsaXN0IHRyYXZlbGxpbmcs
IEkgYW0gd29uZGVyaW5nIGlmIGl0IGlzIHBvc3NpYmxlIHRoYXQgdnhsYW5fZmRiIGlzIGZyZWVk
IHdoZW4gaXQgaXMgYmVpbmcgdXNlZC4gCgpzdGF0aWMgdm9pZCB2eGxhbl9mZGJfZGVzdHJveShz
dHJ1Y3QgdnhsYW5fZGV2ICp2eGxhbiwgc3RydWN0IHZ4bGFuX2ZkYiAqZikKewogICAgICAgbmV0
ZGV2X2RiZyh2eGxhbi0+ZGV2LAogICAgICAgICAgICAgICAgICAiZGVsZXRlICVwTVxuIiwgZi0+
ZXRoX2FkZHIpOwoKICAgICAgIC0tdnhsYW4tPmFkZHJjbnQ7CiAgICAgICB2eGxhbl9mZGJfbm90
aWZ5KHZ4bGFuLCBmLCBmaXJzdF9yZW1vdGVfcnRubChmKSwgUlRNX0RFTE5FSUdIKTsKCiAgICAg
ICBobGlzdF9kZWxfcmN1KCZmLT5obGlzdCk7CiAgICAgICBjYWxsX3JjdSgmZi0+cmN1LCB2eGxh
bl9mZGJfZnJlZSk7Cn0KCgpUaGFua3MKClhpYW9ibwo=
