From: "Xiaobo Yan" <yanxb123@163.com>
Subject: Re:Re: [drivers/net/vxlan]Why rcu_read_lock is not obtained before
 rculist travelling
Date: Wed, 1 Mar 2017 20:40:16 +0800 (CST)
Message-ID: <6fc9b9b7.d935.15a89e2a384.Coremail.yanxb123@163.com>
References: <199cc09e.de3a.15a8508c1f7.Coremail.yanxb123@163.com>
 <CAM_iQpUp+nmLW2i3Gm2YQnq+_EA5ozvgO33fG6k=x+kQx9kt_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64
Cc: "Stephen Hemminger" <stephen@networkplumber.org>,
        "Linux Kernel Network Developers" <netdev@vger.kernel.org>
To: "Cong Wang" <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mproxygzt1.163.com ([113.108.225.5]:49247 "EHLO
        mproxygzt1.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752219AbdCASFt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 13:05:49 -0500
In-Reply-To: <CAM_iQpUp+nmLW2i3Gm2YQnq+_EA5ozvgO33fG6k=x+kQx9kt_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CkhpIENvbmcsCgpUaGFua3MgdmVyeSBtdWNoIGZvciB5b3VyIHJlcGx5LiAgSXQncyBpbmRlZWRl
ZCBhY3F1aXJlZCBieSB1cHBlciBsYXllci4KClRoYW5rcwoKQXQgMjAxNy0wMy0wMSAwNToyOTox
NywgIkNvbmcgV2FuZyIgPHhpeW91Lndhbmdjb25nQGdtYWlsLmNvbT4gd3JvdGU6Cj5PbiBUdWUs
IEZlYiAyOCwgMjAxNyBhdCA2OjAzIEFNLCBYaWFvYm8gWWFuIDx5YW54YjEyM0AxNjMuY29tPiB3
cm90ZToKPj4gQnV0IEkgZG9uoa90IGZpbmQgYW55IHJjdV9yZWFkX2xvY2sgaW52b2tlZCBiZWZv
cmUgdHJhdmVsbGluZyBmZGJfaGVhZCBsaXN0LiAgSW4gdnhsYW5feG1pdCBhbmQgdnhsYW5fc25v
b3AgZnVuY3Rpb24sIHZ4bGFuX2ZpbmRfbWFjIGZ1bmN0aW9uIGlzIGNhbGxlZCB0byBzZWFyY2gg
dGhlIHZ4bGFuX2ZkYiBvZiB0aGUgZHN0X21hYyBvciBzcmNfbWFjLiBUaGVuIGluZm9ybWF0aW9u
IGluIHZ4bGFuX2ZkYiAgaXMgdXNlZCBmb3IgZnVydGhlciBwcm9jZXNzLiAgQnV0IGFzIG5vIHJj
dV9yZWFkX2xvY2sgaXMgb2J0YWluZWQgYmVmb3JlIHRoZSBsaXN0IHRyYXZlbGxpbmcsIEkgYW0g
d29uZGVyaW5nIGlmIGl0IGlzIHBvc3NpYmxlIHRoYXQgdnhsYW5fZmRiIGlzIGZyZWVkIHdoZW4g
aXQgaXMgYmVpbmcgdXNlZC4KPj4KPgo+SW4gYm90aCBSWCBhbmQgVFggcGF0aHMsIHJjdSByZWFk
IGxvY2sgaXMgYWNxdWlyZWQgYnkgdXBwZXIgbGF5ZXIuCj5DaGVjayBfX2Rldl9xdWV1ZV94bWl0
KCkgYW5kIHByb2Nlc3NfYmFja2xvZygpLgo=
