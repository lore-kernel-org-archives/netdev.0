From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: nf_conntrack_sctp: fix build warning
Date: Mon, 24 Nov 2008 13:23:16 +0100
Message-ID: <492A9CB4.3060004@trash.net>
References: <20081123113315.GA16697@localhost> <20081123.135955.202482968.davem@davemloft.net> <20081124000652.GA5424@localhost> <4929FEA9.9090801@cn.fujitsu.com> <20081124011727.GA6462@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040404030709080209020805"
Cc: Wang Chen <wangchen@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081124011727.GA6462@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040404030709080209020805
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Wu Fengguang wrote:
>> print some debug info would be better?
> 
> Like this one?
> +		pr_debug("Empty sctp packet\n");
> 
> Fengguang
> ---
> netfilter: nf_conntrack_sctp: fix build warning
> 
> net/netfilter/nf_conntrack_proto_sctp.c: In function ‘sctp_packet’:
> net/netfilter/nf_conntrack_proto_sctp.c:376: warning: array subscript is above array bounds

The warning is bogus, so we don't need a pr_debug() there.
I've applied your first patch with an unlikely() added and
a comment stating that the warning is bogus.


--------------040404030709080209020805
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="x"

Y29tbWl0IGEzZTI5MTNmZmQzZGVjN2Y2OTc1ZjY4MDAzNTY3MDI2MWFkNWY1NmUKQXV0aG9y
OiBXdSBGZW5nZ3VhbmcgPHdmZ0BsaW51eC5pbnRlbC5jb20+CkRhdGU6ICAgTW9uIE5vdiAy
NCAxMzoxODowMCAyMDA4ICswMTAwCgogICAgbmV0ZmlsdGVyOiBuZl9jb25udHJhY2tfc2N0
cDogZml4IGJ1aWxkIHdhcm5pbmcKICAgIAogICAgbmV0L25ldGZpbHRlci9uZl9jb25udHJh
Y2tfcHJvdG9fc2N0cC5jOiBJbiBmdW5jdGlvbiAnc2N0cF9wYWNrZXQnOgogICAgbmV0L25l
dGZpbHRlci9uZl9jb25udHJhY2tfcHJvdG9fc2N0cC5jOjM3Njogd2FybmluZzogYXJyYXkg
c3Vic2NyaXB0IGlzIGFib3ZlIGFycmF5IGJvdW5kcwogICAgCiAgICBbUGF0cmljazsgYWRk
IHVubGlrZWx5IGFuZCBjb21tZW50IHN0YXRpbmcgdGhhdCB0aGUgd2FybmluZyBpcyBib2d1
c10KICAgIAogICAgU2lnbmVkLW9mZi1ieTogV3UgRmVuZ2d1YW5nIDx3ZmdAbGludXguaW50
ZWwuY29tPgogICAgU2lnbmVkLW9mZi1ieTogUGF0cmljayBNY0hhcmR5IDxrYWJlckB0cmFz
aC5uZXQ+CgpkaWZmIC0tZ2l0IGEvbmV0L25ldGZpbHRlci9uZl9jb25udHJhY2tfcHJvdG9f
c2N0cC5jIGIvbmV0L25ldGZpbHRlci9uZl9jb25udHJhY2tfcHJvdG9fc2N0cC5jCmluZGV4
IGMyYmQ0NTcuLjEyNTllYzYgMTAwNjQ0Ci0tLSBhL25ldC9uZXRmaWx0ZXIvbmZfY29ubnRy
YWNrX3Byb3RvX3NjdHAuYworKysgYi9uZXQvbmV0ZmlsdGVyL25mX2Nvbm50cmFja19wcm90
b19zY3RwLmMKQEAgLTM3Myw2ICszNzMsMTIgQEAgc3RhdGljIGludCBzY3RwX3BhY2tldChz
dHJ1Y3QgbmZfY29ubiAqY3QsCiAJfQogCXdyaXRlX3VubG9ja19iaCgmc2N0cF9sb2NrKTsK
IAorCS8qIEF2b2lkIGJvZ3VzIHdhcm5pbmcsIGdjYyBkb2Vzbid0IHJlYWxpemUgZG9fYmFz
aWNfY2hlY2tzKCkKKwkgKiBndWFyYW50ZWVzIHRoYXQgdGhlcmUgaXMgYXQgbGVhc3Qgb25l
IFNDVFAgY2h1bmsuCisJICovCisJaWYgKHVubGlrZWx5KG5ld19zdGF0ZSA9PSBTQ1RQX0NP
Tk5UUkFDS19NQVgpKQorCQlnb3RvIG91dDsKKwogCW5mX2N0X3JlZnJlc2hfYWNjdChjdCwg
Y3RpbmZvLCBza2IsIHNjdHBfdGltZW91dHNbbmV3X3N0YXRlXSk7CiAKIAlpZiAob2xkX3N0
YXRlID09IFNDVFBfQ09OTlRSQUNLX0NPT0tJRV9FQ0hPRUQgJiYK
--------------040404030709080209020805--
