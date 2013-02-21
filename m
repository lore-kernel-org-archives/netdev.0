From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv2 vringh 1/3] remoteproc: Add support for vringh (Host
	vrings)
Date: Thu, 21 Feb 2013 17:07:29 +1030
Message-ID: <8738wqgok6.fsf@rustcorp.com.au>
References: <1360669793-6921-1-git-send-email-sjur.brandeland@stericsson.com>
	<1360669793-6921-2-git-send-email-sjur.brandeland@stericsson.com>
	<CAK=Wgbb0EeiCh504jsoX+izzi+ZogfEDttz2cHRd4pVXvQunQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>,
	Sjur =?utf-8?Q?Br=C3=A6ndelan?= =?utf-8?Q?d?= <sjur@brendeland.net>,
	Linus Walleij <linus.walleij@linaro.org>, Ido Yariv <ido@wizery.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Erwan Yvin <erwan.yvin@stericsson.com>,
	virtualization <virtualization@lists.linux-foundation.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Ohad Ben-Cohen <ohad@wizery.com>, Sjur =?utf-8?Q?Br=C3=A6ndeland?=
	<sjur.brandeland@stericsson.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAK=Wgbb0EeiCh504jsoX+izzi+ZogfEDttz2cHRd4pVXvQunQw@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

T2hhZCBCZW4tQ29oZW4gPG9oYWRAd2l6ZXJ5LmNvbT4gd3JpdGVzOgo+IEhpIFNqdXIsCj4KPiBP
biBUdWUsIEZlYiAxMiwgMjAxMyBhdCAxOjQ5IFBNLCAgPHNqdXIuYnJhbmRlbGFuZEBzdGVyaWNz
c29uLmNvbT4gd3JvdGU6Cj4+IEZyb206IFNqdXIgQnLDpm5kZWxhbmQgPHNqdXIuYnJhbmRlbGFu
ZEBzdGVyaWNzc29uLmNvbT4KPj4KPj4gQWRkIGZ1bmN0aW9ucyBmb3IgY3JlYXRpbmcsIGRlbGV0
aW5nIGFuZCBraWNraW5nIGhvc3Qtc2lkZSB2aXJ0aW8gcmluZ3MuCj4+Cj4+IFRoZSBob3N0IHJp
bmcgaXMgbm90IGludGVncmF0ZWQgd2l0aCB2aXJ0aXF1ZXVlcyBhbmQgY2Fubm90IGJlIG1hbmFn
ZWQKPj4gdGhyb3VnaCB2aXJ0aW8tY29uZmlnLgo+Cj4gSXMgdGhhdCBhbiBpbmhlcmVudCBkZXNp
Z24vaXNzdWUgb2YgdnJpbmdoIG9yIGp1c3QgYSBkZXNjcmlwdGlvbiBvZgo+IHRoZSBjdXJyZW50
IHZyaW5naCBjb2RlID8KCkl0J3MgYnkgZGVzaWduLiAgVGhlIHByb2R1Y2VyICh2aXJ0cXVldWUp
IGFuZCBjb25zdW1lciAodnJpbmdoKSBhcmUgdHdvCnNpZGVzIG9mIHRoZSBzYW1lIGNvaW4sIGJ1
dCB0aGV5IGRvIGRpZmZlcmVudCB0aGluZ3MuCgp2aXJ0cXVldWUgaXMgYSBzbGlnaHRseSBoaWdo
ZXIgbGV2ZWwgYWJzdHJhY3Rpb24gd2hpY2ggYXNzdW1lcyBhCnZpcnRpb19kZXZpY2UsIGJlY2F1
c2UgZXZlcnkgdXNlciBzbyBmYXIgaGFzIGhhZCBvbmUuICB2cmluZ2ggZG9lc24ndCwKYmVjYXVz
ZSBpdCdzIGFsc28gYWltZWQgdG8gdW5kZXJsaWUgdmhvc3QuYyB3aGljaCBkb2Vzbid0IHJlYWxs
eSBoYXZlCm9uZS4KCj4gVGhpcyBpcyBwb3NzaWJsZSBvZiBjb3Vyc2UgdGhhbmtzIHRvIHRoZSBh
YnN0cmFjdGlvbiBwcm92aWRlZCBieQo+IHZpcnRpbzogcmVtb3RlcHJvYyBvbmx5IGltcGxlbWVu
dHMgYSBzZXQgb2YgY2FsbGJhY2tzIHdoaWNoIHZpcnRpbwo+IGludm9rZXMgd2hlbiBuZWVkZWQu
Cj4KPiBEbyB3ZSBub3Qgd2FudCB0byBmb2xsb3cgYSBzaW1pbGFyIGRlc2lnbiBzY2hlbWUgd2l0
aCB2cmluZ2ggPwoKSG1tLi4uIEkgY2xlYXJseSBqdW1wZWQgdGhlIGd1biwgYXNzdW1pbmcgY29u
c2Vuc3VzIHdhcyBhbHJlYWR5IHJlYWNoZWQuCkkgaGF2ZSBwdXQgdGhlc2UgcGF0Y2hlcyAqYmFj
ayogaW50byBwZW5kaW5nLXJlYmFzZXMsIGFuZCB0aGV5IHdpbGwgbm90CmJlIG1lcmdlZCB0aGlz
IG1lcmdlIHdpbmRvdy4KCkNoZWVycywKUnVzdHkuCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fClZpcnR1YWxpemF0aW9uIG1haWxpbmcgbGlzdApWaXJ0dWFs
aXphdGlvbkBsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91
bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby92aXJ0dWFsaXphdGlvbg==
