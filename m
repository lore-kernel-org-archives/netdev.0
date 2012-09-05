From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 1/4] net: mvneta: driver for Marvell Armada 370/XP
 network unit
Date: Wed, 5 Sep 2012 09:32:14 +0200
Message-ID: <20120905093214.379ef16c@skate>
References: <1346764004-16332-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1346764004-16332-2-git-send-email-thomas.petazzoni@free-electrons.com>
 <201209041436.36430.arnd@arndb.de> <20120904175610.2c2934f1@skate>
 <20120904183125.GB14683@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Lior Amsalem <alior@marvell.com>, Ike Pan <ike.pan@canonical.com>,
 Nadav Haklai <nadavh@marvell.com>, Ian Molton <ian.molton@codethink.co.uk>,
 Lennert Buytenhek <kernel@wantstofly.org>, David Marlin <dmarlin@redhat.com>,
 Rami Rosen <rosenr@marvell.com>, Yehuda Yitschak <yehuday@marvell.com>,
 Jani Monoses <jani.monoses@canonical.com>, Tawfik Bayouk <tawfik@marvell.com>,
 Dan Frazier <dann.frazier@canonical.com>, Eran Ben-Avi <benavi@marvell.com>,
 Li Li <li.li@canonical.com>, Leif Lindholm <leif.lindholm@arm.com>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>,
 Jon Masters <jcm@redhat.com>, Ben Dooks <ben-linux@fluff.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org, Chris Van Hoof <vanhoof@canonical.com>,
 Nicolas Pitre <nico@fluxnic.net>, netdev@vger.k
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20120904183125.GB14683@lunn.ch>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

SGVsbG8gQW5kcmV3LAoKTGUgVHVlLCA0IFNlcCAyMDEyIDIwOjMxOjI1ICswMjAwLApBbmRyZXcg
THVubiA8YW5kcmV3QGx1bm4uY2g+IGEgw6ljcml0IDoKCj4gSSd2ZSB1c2VkIE1hcnZlbGwgc3dp
dGNoIGNoaXBzZXRzLCB3aGljaCBoYXZlIGEgcGh5IHBvbGxpbmcgdW5pdCwKPiBQUFUuIFRoaXMg
c291bmRzIHZlcnkgc2ltaWxhci4gWW91IGNhbiBkbyBhIGxvdCB3aXRoIHRoZSBQUFUsIGJ1dCB3
aGVuCj4geW91IHdhbnQgdG8gY29uZmlndXJlIHN1YnNldHMgb2YgYXV0by1uZWdvdGlhdGlvbiBy
YXRlcy9kdXBsZXggbW9kZXMsCj4gb3IgZml4ZWQgc3BlZWRzL2R1cGxleCBtb2RlcywgdGhlIFBQ
VSBjb3VsZCBub3QgZG8gaXQuIFlvdSBoYWQgdG8KPiBkaXNhYmxlIHRoZSBQUFUgYW5kIGNvbmZp
Z3VyZSB0aGUgUEhZIGRpcmVjdGx5Lgo+IAo+IEkgc2VlIHlvdSBoYXZlIHNvbWUgb2YgdGhlIGV0
aHRvb2xzIEFQSSBjYWxscyBpbXBsZW1lbnRlZCwgYnV0IG5vdCB0aGUKPiBvbmVzIG5lZWRlZCBm
b3IgYXV0by1uZWcgYW5kIHJhdGVzL2R1cGxleCBtb2RlIGNvbmZpZ3VyYXRpb25zLiBEb2VzCj4g
dGhlIG5ldGEgUFBVIHN1cHBvcnQgdGhpcywgb3Igd2lsbCB5b3UgbmVlZCB0byBleHBvcnQgdGhl
IE1ESU8gYnVzIGZvcgo+IHRoZXNlIHNvcnRzIG9mIGNvbmZpZ3VyYXRpb24gb3B0aW9ucz8KClRo
ZXJlJ3Mgbm90aGluZyBuYW1lZCAnUFBVJyBpbiB0aGUgZGF0YXNoZWV0IGZvciBBcm1hZGEgWFAv
MzcwLCBidXQgdGhlCkV0aGVybmV0IGNvbnRyb2xsZXIgcmVnaXN0ZXJzIGluZGVlZCBhbGxvdyB0
byBjaGFuZ2UgdGhlCmF1dG8tbmVnb3RpYXRpb24sIGR1cGxleCBhbmQgc3BlZWQgd2l0aG91dCB0
YWxraW5nIHRvIHRoZSBQSFkuCgpJbiBhZGRpdGlvbiB0byB0aGUgR01BQ19TVEFUVVMgcmVnaXN0
ZXIgKG9mZnNldCAweDJDMTApIHRoYXQgdGhlIGRyaXZlcgpjdXJyZW50bHkgdXNlcyB0byBmaW5k
IG91dCB0aGUgc3RhdGUgb2YgdGhlIGxpbmsgKHVwL2Rvd24sIHNwZWVkLApkdXBsZXgpLCB0aGVy
ZSBpcyBhICJQb3J0IEF1dG8tTmVnb3RpYXRpb24gQ29uZmlndXJhdGlvbgpSZWdpc3RlciIgKG9m
ZnNldCAweDJDMEMpLCB3aGljaCBhbGxvd3MgdG8gc2V0OgoKICogTWFudWFsIGR1cGxleCBvciBh
dXRvIGR1cGxleCBkZXRlY3Rpb24KICogSWYgbWFudWFsIGR1cGxleCwgY2hvb3NlIGZ1bGwvaGFs
ZgogKiBNYW51YWwgb3IgYXV0b21hdGljIGRldGVjdGlvbiBvZiBmbG93IGNvbnRyb2wKICogSWYg
bWFudWFsIGZsb3cgY29udHJvbCwgZGVjaWRlIHRoZSBmbG93IGNvbnRyb2wgdmFsdWUKICogTWFu
dWFsIG9yIGF1dG9tYXRpYyBkZXRlY3Rpb24gb2Ygc3BlZWQKICogSWYgbWFudWFsIHNwZWVkLCBz
ZXQgdGhlIHNwZWVkIHZhbHVlCgpBbmQgYSBmZXcgb3RoZXIgdGhpbmdzLiBTbyBpbmRlZWQsIHdl
IGNhbiBjb25maWd1cmUgdGhlIFBIWSBwYXJhbWV0ZXJzCndpdGhvdXQgaGF2aW5nIHRvIHRhbGsg
dG8gdGhlIFBIWSBkaXJlY3RseS4KCkJlc3QgcmVnYXJkcywKClRob21hcwotLSAKVGhvbWFzIFBl
dGF6em9uaSwgRnJlZSBFbGVjdHJvbnMKS2VybmVsLCBkcml2ZXJzLCByZWFsLXRpbWUgYW5kIGVt
YmVkZGVkIExpbnV4CmRldmVsb3BtZW50LCBjb25zdWx0aW5nLCB0cmFpbmluZyBhbmQgc3VwcG9y
dC4KaHR0cDovL2ZyZWUtZWxlY3Ryb25zLmNvbQoKX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX18KbGludXgtYXJtLWtlcm5lbCBtYWlsaW5nIGxpc3QKbGludXgt
YXJtLWtlcm5lbEBsaXN0cy5pbmZyYWRlYWQub3JnCmh0dHA6Ly9saXN0cy5pbmZyYWRlYWQub3Jn
L21haWxtYW4vbGlzdGluZm8vbGludXgtYXJtLWtlcm5lbAo=
