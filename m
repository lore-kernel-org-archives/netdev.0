From: devik <devik@cdi.cz>
Subject: Re: HTB 2.6.0-test10 oops related patch
Date: Sun, 7 Dec 2003 12:30:20 +0100 (CET)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.33.0312071218400.635-200000@devix>
References: <20031206231047.01257548.davem@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-49484585-1070796620=:635"
Cc: <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>,
	<daniel.blueman@gmx.net>
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031206231047.01257548.davem@redhat.com>
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--8323328-49484585-1070796620=:635
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hello Dave,

I just spotted the second bug too. (For those interested it is described
in the patch).
Please revert the small patch I sent you yesterday before applying the
new one. It contains yesterday's one too (it is because it is for 2.4 too).
Please apply it against both 2.4.23 and 2.6.0-test10. It should apply
cleanly in 2.4.23 case and with some offsets to 2.6.0-test10.

Patch comments:
- Fixed oops in debugging of enqueue/requeue.
- Fixed oops in htb_destroy.

Note that I tested 2.6 only because I'm still downloading 2.4.22 patch
on my slow line. I just wanted to sent the patch ASAP. I'll inform you
about result later but I expect no problems.

-------------------------------
    Martin Devera aka devik
Linux kernel QoS/HTB maintainer
  http://luxik.cdi.cz/~devik/

On Sat, 6 Dec 2003, David S. Miller wrote:

> On Sat, 6 Dec 2003 15:18:37 +0100 (CET)
> devik <devik@cdi.cz> wrote:
>
> > I discovered reason of the first Daniel's OOPS. It is change
> > which was not forward-ported to 2.6.
> > It is attached.
>
> Thanks a lot for tracking this problem down Devik.
>
> Patch applied, thanks again.
>
>

--8323328-49484585-1070796620=:635
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="htb_k2.6.0t10_n_k2.4.23_to_3.14.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.33.0312071230200.635@devix>
Content-Description: 
Content-Disposition: attachment; filename="htb_k2.6.0t10_n_k2.4.23_to_3.14.diff"

LS0tIHNjaF9odGIuMjQyMy5jCVN1biBEZWMgIDcgMTE6NTA6NDIgMjAwMw0K
KysrIHNjaF9odGIuYwlTdW4gRGVjICA3IDEyOjEyOjM5IDIwMDMNCkBAIC0y
Myw3ICsyMyw3IEBADQogICoJCQlzcG90dGVkIGJ1ZyBpbiBkZXF1ZXVlIGNv
ZGUgYW5kIGhlbHBlZCB3aXRoIGZpeA0KICAqCQlhbmQgbWFueSBvdGhlcnMu
IHRoYW5rcy4NCiAgKg0KLSAqICRJZDogc2NoX2h0Yi5jLHYgMS4yNCAyMDAz
LzA3LzI4IDE1OjI1OjIzIGRldmlrIEV4cCBkZXZpayAkDQorICogJElkOiBz
Y2hfaHRiLmMsdiAxLjI1IDIwMDMvMTIvMDcgMTE6MDg6MjUgZGV2aWsgRXhw
IGRldmlrICQNCiAgKi8NCiAjaW5jbHVkZSA8bGludXgvY29uZmlnLmg+DQog
I2luY2x1ZGUgPGxpbnV4L21vZHVsZS5oPg0KQEAgLTc1LDcgKzc1LDcgQEAN
CiAjZGVmaW5lIEhUQl9IWVNURVJFU0lTIDEvKiB3aGV0aGVyIHRvIHVzZSBt
b2RlIGh5c3RlcmVzaXMgZm9yIHNwZWVkdXAgKi8NCiAjZGVmaW5lIEhUQl9R
TE9DSyhTKSBzcGluX2xvY2tfYmgoJihTKS0+ZGV2LT5xdWV1ZV9sb2NrKQ0K
ICNkZWZpbmUgSFRCX1FVTkxPQ0soUykgc3Bpbl91bmxvY2tfYmgoJihTKS0+
ZGV2LT5xdWV1ZV9sb2NrKQ0KLSNkZWZpbmUgSFRCX1ZFUiAweDMwMDBkCS8q
IG1ham9yIG11c3QgYmUgbWF0Y2hlZCB3aXRoIG51bWJlciBzdXBsaWVkIGJ5
IFRDIGFzIHZlcnNpb24gKi8NCisjZGVmaW5lIEhUQl9WRVIgMHgzMDAwZQkv
KiBtYWpvciBtdXN0IGJlIG1hdGNoZWQgd2l0aCBudW1iZXIgc3VwbGllZCBi
eSBUQyBhcyB2ZXJzaW9uICovDQogDQogI2lmIEhUQl9WRVIgPj4gMTYgIT0g
VENfSFRCX1BST1RPVkVSDQogI2Vycm9yICJNaXNtYXRjaGVkIHNjaF9odGIu
YyBhbmQgcGt0X3NjaC5oIg0KQEAgLTcxNyw3ICs3MTcsNyBAQA0KIA0KICAg
ICBzY2gtPnEucWxlbisrOw0KICAgICBzY2gtPnN0YXRzLnBhY2tldHMrKzsg
c2NoLT5zdGF0cy5ieXRlcyArPSBza2ItPmxlbjsNCi0gICAgSFRCX0RCRygx
LDEsImh0Yl9lbnFfb2sgY2w9JVggc2tiPSVwXG4iLGNsP2NsLT5jbGFzc2lk
OjAsc2tiKTsNCisgICAgSFRCX0RCRygxLDEsImh0Yl9lbnFfb2sgY2w9JVgg
c2tiPSVwXG4iLChjbCAmJiBjbCAhPSBIVEJfRElSRUNUKT9jbC0+Y2xhc3Np
ZDowLHNrYik7DQogICAgIHJldHVybiBORVRfWE1JVF9TVUNDRVNTOw0KIH0N
CiANCkBAIC03NDUsNyArNzQ1LDcgQEANCiAJICAgIGh0Yl9hY3RpdmF0ZSAo
cSxjbCk7DQogDQogICAgIHNjaC0+cS5xbGVuKys7DQotICAgIEhUQl9EQkco
MSwxLCJodGJfcmVxX29rIGNsPSVYIHNrYj0lcFxuIixjbD9jbC0+Y2xhc3Np
ZDowLHNrYik7DQorICAgIEhUQl9EQkcoMSwxLCJodGJfcmVxX29rIGNsPSVY
IHNrYj0lcFxuIiwoY2wgJiYgY2wgIT0gSFRCX0RJUkVDVCk/Y2wtPmNsYXNz
aWQ6MCxza2IpOw0KICAgICByZXR1cm4gTkVUX1hNSVRfU1VDQ0VTUzsNCiB9
DQogDQpAQCAtMTM5NiwxMSArMTM5NiwxNiBAQA0KICNpZmRlZiBIVEJfUkFU
RUNNDQogCWRlbF90aW1lcl9zeW5jICgmcS0+cnR0aW0pOw0KICNlbmRpZg0K
KwkvKiBUaGlzIGxpbmUgdXNlZCB0byBiZSBhZnRlciBodGJfZGVzdHJveV9j
bGFzcyBjYWxsIGJlbG93DQorCSAgIGFuZCBzdXJwcmlzaW5nbHkgaXQgd29y
a2VkIGluIDIuNC4gQnV0IGl0IG11c3QgcHJlY2VkZSBpdCANCisJICAgYmVj
YXVzZSBmaWx0ZXIgbmVlZCBpdHMgdGFyZ2V0IGNsYXNzIGFsaXZlIHRvIGJl
IGFibGUgdG8gY2FsbA0KKwkgICB1bmJpbmRfZmlsdGVyIG9uIGl0ICh3aXRo
b3V0IE9vcHMpLiAqLw0KKwlodGJfZGVzdHJveV9maWx0ZXJzKCZxLT5maWx0
ZXJfbGlzdCk7DQorCQ0KIAl3aGlsZSAoIWxpc3RfZW1wdHkoJnEtPnJvb3Qp
KSANCiAJCWh0Yl9kZXN0cm95X2NsYXNzIChzY2gsbGlzdF9lbnRyeShxLT5y
b290Lm5leHQsDQogCQkJCQlzdHJ1Y3QgaHRiX2NsYXNzLHNpYmxpbmcpKTsN
CiANCi0JaHRiX2Rlc3Ryb3lfZmlsdGVycygmcS0+ZmlsdGVyX2xpc3QpOw0K
IAlfX3NrYl9xdWV1ZV9wdXJnZSgmcS0+ZGlyZWN0X3F1ZXVlKTsNCiAJTU9E
X0RFQ19VU0VfQ09VTlQ7DQogfQ0KQEAgLTE0OTMsNyArMTQ5OCw3IEBADQog
CQljbC0+bWFnaWMgPSBIVEJfQ01BR0lDOw0KICNlbmRpZg0KIA0KLQkJLyog
Y3JlYXRlIGxlYWYgcWRpc2MgZWFybHkgYmVjYXVzZSBpdCB1c2VzIGttYWxs
b2MoR1BGX0tFUk5FTCkNCisJCS8qIGNyZWF0ZSBsZWFmIHFkaXNjIGVhcmx5
IGJlY2F1c2UgaXQgdXNlcyBrbWFsbG9jKEdGUF9LRVJORUwpDQogCQkgICBz
byB0aGF0IGNhbid0IGJlIHVzZWQgaW5zaWRlIG9mIHNjaF90cmVlX2xvY2sN
CiAJCSAgIC0tIHRoYW5rcyB0byBLYXJsaXMgUGVpc2VuaWVrcyAqLw0KIAkJ
bmV3X3EgPSBxZGlzY19jcmVhdGVfZGZsdChzY2gtPmRldiwgJnBmaWZvX3Fk
aXNjX29wcyk7DQo=
--8323328-49484585-1070796620=:635--
