From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GIT]: Networking
Date: Fri, 17 Oct 2008 13:55:42 +0200
Message-ID: <48F87D3E.5020007@trash.net>
References: <20081015.163817.193700221.davem@davemloft.net> <20081017082138.GA23155@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050308010509050000040801"
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62597 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877AbYJQLzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 07:55:48 -0400
In-Reply-To: <20081017082138.GA23155@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050308010509050000040801
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Ingo Molnar wrote:
>> Pablo Neira Ayuso (1):
>>       netfilter: ctnetlink: remove bogus module dependency between ctnetlink and nf_nat
> 
> FYI, got a common build failure with latest -git, and bisected it back 
> to the commit above. Config attached, error log and bisect log below.
> 
> (The build failure output is at the bottom, it comes after dozens of 
> build warnings all across the kernel.)
>
> net/netfilter/nf_conntrack_netlink.c:819: warning: ‘enum nf_nat_manip_type’ declared inside parameter list
> net/netfilter/nf_conntrack_netlink.c:819: warning: its scope is only this definition or declaration, which is probably not what you want
> net/netfilter/nf_conntrack_netlink.c:818: error: parameter 2 (‘manip’) has incomplete type

Thanks Ingo. I just sent this patch to Benjamin Herrenschmidt
for testing.


--------------050308010509050000040801
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="x"

Y29tbWl0IGNmYmI5NjZlMGE4NGViNzVlOGU3YzE5Mjk1M2VjZjNjYTQ4YTk0MjAKQXV0aG9y
OiBQYXRyaWNrIE1jSGFyZHkgPGthYmVyQHRyYXNoLm5ldD4KRGF0ZTogICBGcmkgT2N0IDE3
IDEzOjUwOjM1IDIwMDggKzAyMDAKCiAgICBuZXRmaWx0ZXI6IGN0bmV0bGluazogZml4IGNv
bXBpbGF0aW9uIGVycm9yCiAgICAKICAgIEZpeCBjb21waWxhdGlvbiBlcnJvciBvbiAoYXQg
bGVhc3QpIHBwYzoKICAgIAogICAgL2hvbWUvYmVuaC9rZXJuZWxzL2xpbnV4LXBvd2VycGMv
bmV0L25ldGZpbHRlci9uZl9jb25udHJhY2tfbmV0bGluay5jOjgxOTogd2FybmluZzogXHUy
MDE4ZW51bSBuZl9uYXRfbWFuaXBfdHlwZVx1MjAxOSBkZWNsYXJlZCBpbnNpZGUgcGFyYW1l
dGVyIGxpc3QKICAgIC9ob21lL2Jlbmgva2VybmVscy9saW51eC1wb3dlcnBjL25ldC9uZXRm
aWx0ZXIvbmZfY29ubnRyYWNrX25ldGxpbmsuYzo4MTk6IHdhcm5pbmc6IGl0cyBzY29wZSBp
cyBvbmx5IHRoaXMgZGVmaW5pdGlvbiBvciBkZWNsYXJhdGlvbiwgd2hpY2ggaXMgcHJvYmFi
bHkgbm90IHdoYXQgeW91IHdhbnQKICAgIAogICAgU2lnbmVkLW9mZi1ieTogUGF0cmljayBN
Y0hhcmR5IDxrYWJlckB0cmFzaC5uZXQ+CgpkaWZmIC0tZ2l0IGEvbmV0L25ldGZpbHRlci9u
Zl9jb25udHJhY2tfbmV0bGluay5jIGIvbmV0L25ldGZpbHRlci9uZl9jb25udHJhY2tfbmV0
bGluay5jCmluZGV4IDA4ZTgyZDYuLmRlYWNlMDYgMTAwNjQ0Ci0tLSBhL25ldC9uZXRmaWx0
ZXIvbmZfY29ubnRyYWNrX25ldGxpbmsuYworKysgYi9uZXQvbmV0ZmlsdGVyL25mX2Nvbm50
cmFja19uZXRsaW5rLmMKQEAgLTM5LDYgKzM5LDcgQEAKICNpbmNsdWRlIDxuZXQvbmV0Zmls
dGVyL25mX2Nvbm50cmFja190dXBsZS5oPgogI2luY2x1ZGUgPG5ldC9uZXRmaWx0ZXIvbmZf
Y29ubnRyYWNrX2FjY3QuaD4KICNpZmRlZiBDT05GSUdfTkZfTkFUX05FRURFRAorI2luY2x1
ZGUgPG5ldC9uZXRmaWx0ZXIvbmZfbmF0Lmg+CiAjaW5jbHVkZSA8bmV0L25ldGZpbHRlci9u
Zl9uYXRfY29yZS5oPgogI2luY2x1ZGUgPG5ldC9uZXRmaWx0ZXIvbmZfbmF0X3Byb3RvY29s
Lmg+CiAjZW5kaWYK
--------------050308010509050000040801--
