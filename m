From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 0/8] Use correctly the Xen memory terminologies in Linux
Date: Tue, 28 Jul 2015 14:06:21 -0700
Message-ID: <55B7EECD.8050605@zytor.com>
References: <1438095769-2560-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-fbdev@vger.kernel.org, x86@kernel.org, netdev@vger.kernel.org,
 Jiri Slaby <jslaby@suse.com>, Thomas Gleixner <tglx@linutronix.de>,
 Russell King <linux@arm.linux.org.uk>, linux-scsi@vger.kernel.org,
 Tomi Valkeinen <tomi.valkeinen@ti.com>, stefano.stabellini@eu.citrix.com,
 Ingo Molnar <mingo@redhat.com>, linux-input@vger.kernel.org,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 ian.campbell@citrix.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 "James E.J. Bottomley" <JBottomley@odin.com>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>,
 linux-arm-kernel@lists.infradead.org, Juergen Gross <jgross@suse.com>,
 Wei Liu <wei.liu2@citrix.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Dmitry Torokhov <dmitry.torokhov@gmail.com>, linux-kernel@vger.kernel.org,
 David Vrabel <david.vrabel@citrix.com>, linux-api@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.or
To: Julien Grall <julien.grall@citrix.com>, xen-devel@lists.xenproject.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1438095769-2560-1-git-send-email-julien.grall@citrix.com>
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

T24gMDcvMjgvMjAxNSAwODowMiBBTSwgSnVsaWVuIEdyYWxsIHdyb3RlOgo+IEhpIGFsbCwKPiAK
PiBUaGlzIHBhdGNoIHNlcmllcyBhaW1zIHRvIHVzZSB0aGUgbWVtb3J5IHRlcm1pbm9sb2dpZXMg
ZGVzY3JpYmVkIGluCj4gaW5jbHVkZS9saW51eC9tbS5oIFsxXSBmb3IgTGludXggeGVuIGNvZGUu
Cj4gCj4gTGludXggaXMgdXNpbmcgbWlzdGFrZW5seSBNRk4gd2hlbiBHRk4gaXMgbWVhbnQsIEkg
c3VzcGVjdCB0aGlzIGlzIGJlY2F1c2UgdGhlCj4gZmlyc3Qgc3VwcG9ydCBvZiBYZW4gd2FzIGZv
ciBQVi4gVGhpcyBoYXMgYnJvdWdodCBzb21lIG1pc2ltcGxlbWVudGF0aW9uCj4gb2YgbWVtb3J5
IGhlbHBlcnMgb24gQVJNIGFuZCBtYWtlIHRoZSBkZXZlbG9wcGVyIGNvbmZ1c2VkIGFib3V0IHRo
ZSBleHBlY3RlZAo+IGJlaGF2aW9yLgo+IAo+IEZvciBpbnN0YW5jZSwgd2l0aCBwZm5fdG9fbWZu
LCB3ZSBleHBlY3QgdG8gZ2V0IGEgTUZOIGJhc2VkIG9uIHRoZSBuYW1lLgo+IEFsdGhvdWdoLCBp
ZiB3ZSBsb29rIGF0IHRoZSBpbXBsZW1lbnRhdGlvbiBvbiB4ODYsIGl0J3MgcmV0dXJuaW5nIGEg
R0ZOLgo+IE1vc3Qgb2YgdGhlIGNhbGxlcnMgYXJlIGFsc28gdXNpbmcgaXQgdGhpcyB3YXkuCj4g
Cj4gVGhlIGZpcnN0IDIgcGF0Y2hlcyBvZiB0aGlzIHNlcmllcyBpcyBBUk0gcmVsYXRlZCBpbiBv
cmRlciB0byByZW1vdmUKPiBQViBzcGVjaWZpYyBoZWxwZXJzIHdoaWNoIHNob3VsZCBub3QgYmUg
dXNlZCBhbmQgZml4aW5nIHRoZSBpbXBsZW1lbnRhdGlvbiBvZgo+IHBmbl90b19tZm4uCj4gCj4g
VGhlIHJlc3Qgb2YgdGhlIHNlcmllcyBpcyBoZXJlIHJlbmFtZSBtb3N0IG9mIHRoZSB1c2FnZSBp
biB0aGUgY29tbW9uIGNvZGUKPiBvZiBNRk4gdG8gR0ZOLiBJIGFsc28gdG9vayB0aGUgb3Bwb3J0
dW5pdHkgdG8gcmVwbGFjZSBtb3N0IG9mIHRoZSBjYWxsIHRvCj4gcGZuX3RvX2dmbiBpbiB0aGUg
Y29tbW9uIGNvZGUgYnkgcGFnZV90b19nZm4gYXZvaWQgY29uc3RydWN0aW9uIHN1Y2gKPiBhcyBw
Zm5fdG9fZ2ZuKHBhZ2VfdG9fcGZuKC4uLikuCj4gCj4gTm90ZSB0aGUgb25lIHhlbi1ibGtmcm9u
dCB3aWxsIGJlIGRyb3BwZWQgYnkgNjRLIHNlcmllcyBbMl0sIEkgY2FuIGluY2x1ZGUgaXQKPiBp
ZiBuZWNlc3NhcnkuCj4gCgpDYW4gd2UgYWN0dWFsbHkgZ2V0IHNvbWUgZG9jdW1lbnRhdGlvbiBm
b3IgWGVuIGJlZm9yZSBzdGFydGluZyB0byBjaGFuZ2UKbmFtZXMgYXJvdW5kPwoKCS1ocGEKCgpf
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpMaW51eHBwYy1k
ZXYgbWFpbGluZyBsaXN0CkxpbnV4cHBjLWRldkBsaXN0cy5vemxhYnMub3JnCmh0dHBzOi8vbGlz
dHMub3psYWJzLm9yZy9saXN0aW5mby9saW51eHBwYy1kZXY=
