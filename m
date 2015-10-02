From: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Subject: RE: [v3 1/8] devres: add devm_alloc_percpu()
Date: Fri, 2 Oct 2015 09:16:42 +0000
Message-ID: <BL2PR03MB54503928C025D7EAF9F8814E64B0@BL2PR03MB545.namprd03.prod.outlook.com>
References: <1443106819-5549-1-git-send-email-madalin.bucur@freescale.com>
 <1443106819-5549-2-git-send-email-madalin.bucur@freescale.com>
 <20151002010041.GA4245@home.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
 Roy Pledge <roy.pledge@freescale.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "ppc@mindchasers.com" <ppc@mindchasers.com>, "stsp@list.ru" <stsp@list.ru>,
 Liberman Igal <Igal.Liberman@freescale.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "joe@perches.com" <joe@perches.com>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Scott Wood <scottwood@freescale.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20151002010041.GA4245@home.buserror.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQo+IEZyb206IFdvb2QgU2NvdHQtQjA3NDIxCj4g
U2VudDogRnJpZGF5LCBPY3RvYmVyIDAyLCAyMDE1IDQ6MDEgQU0KPiAKPiBPbiBUaHUsIFNlcCAy
NCwgMjAxNSBhdCAwNjowMDoxMlBNICswMzAwLCBNYWRhbGluIEJ1Y3VyIHdyb3RlOgo+ID4gSW50
cm9kdWNlIG1hbmFnZWQgY291bnRlcnBhcnRzIGZvciBhbGxvY19wZXJjcHUoKSBhbmQgZnJlZV9w
ZXJjcHUoKS4KPiA+IEFkZCBkZXZtX2FsbG9jX3BlcmNwdSgpIGFuZCBkZXZtX2ZyZWVfcGVyY3B1
KCkgaW50byB0aGUgbWFuYWdlZAo+ID4gaW50ZXJmYWNlcyBsaXN0Lgo+ID4KPiA+IFNpZ25lZC1v
ZmYtYnk6IE1hZGFsaW4gQnVjdXIgPG1hZGFsaW4uYnVjdXJAZnJlZXNjYWxlLmNvbT4KPiA+IFRl
c3RlZC1ieTogTWFkYWxpbi1DcmlzdGlhbiBCdWN1ciA8bWFkYWxpbi5idWN1ckBmcmVlc2NhbGUu
Y29tPgo+ID4gLS0tCj4gPiAgRG9jdW1lbnRhdGlvbi9kcml2ZXItbW9kZWwvZGV2cmVzLnR4dCB8
ICA0ICsrKwo+ID4gIGRyaXZlcnMvYmFzZS9kZXZyZXMuYyAgICAgICAgICAgICAgICAgfCA2NAo+
ICsrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrCj4gPiAgaW5jbHVkZS9saW51eC9k
ZXZpY2UuaCAgICAgICAgICAgICAgICB8IDE5ICsrKysrKysrKysrCj4gPiAgMyBmaWxlcyBjaGFu
Z2VkLCA4NyBpbnNlcnRpb25zKCspCj4gCj4gR3JlZyBLSCBuZWVkcyB0byBiZSBDQ2VkIG9uIGFu
eSBkcml2ZXJzL2Jhc2UgY2hhbmdlcy4KPiAKPiAtU2NvdHQKClRoYW5rIHlvdSwgSSB3aWxsIGFk
ZCBoaW0uCgpNYWRhbGluCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fCkxpbnV4cHBjLWRldiBtYWlsaW5nIGxpc3QKTGludXhwcGMtZGV2QGxpc3RzLm96bGFi
cy5vcmcKaHR0cHM6Ly9saXN0cy5vemxhYnMub3JnL2xpc3RpbmZvL2xpbnV4cHBjLWRldg==
