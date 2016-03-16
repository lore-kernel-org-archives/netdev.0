From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] openvswitch: call only into reachable nf-nat
	code
Date: Wed, 16 Mar 2016 14:56:51 +0100
Message-ID: <2159518.ilphXU8bxQ@wuerfel>
References: <1458132481-318209-1-git-send-email-arnd@arndb.de>
 <20160316132536.GA29550@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Joe Stringer <joestringer-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20160316132536.GA29550@salvia>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

T24gV2VkbmVzZGF5IDE2IE1hcmNoIDIwMTYgMTQ6MjU6MzYgUGFibG8gTmVpcmEgQXl1c28gd3Jv
dGU6Cj4gTm90IHJlbGF0ZWQgd2l0aCB0aGlzIHBhdGNoLCBqdXN0IGEgc2lkZSBub3RlL3JlY29t
bWVuZGF0aW9uLgo+IAo+IEkgdW5kZXJzdGFuZCB0aGlzIGNvZGUganVzdCBnb3QgaW50byB0cmVl
LCBhbmQgdGhhdCB0aGlzIG5lZWRzIGEgYml0Cj4gd29yay9pdGVyYXRpb25zIGJ1dCB0aGlzIHRo
aW5nIGFib3ZlIGlzIHVnbHksIEkgd29uZGVyIGlmIHRoZXJlIGlzIGEKPiBiZXR0ZXIgd2F5IHRv
IGF2b2lkIHRoaXMuCj4gCj4gUHJvYmFibHkgd2l0aCBzb21lIG1vZHVsYXJpemF0aW9uIG9mIHRo
ZSBvcGVudnN3aXRjaCBjb2RlIHRoaXMgd2lsbAo+IGxvb2sgYmV0dGVyLCBJIG1lYW46Cj4gCj4g
MSkgYWRkaW5nIEtjb25maWcgc3dpdGNoZXMgdG8gZW5hYmxlIGNvbm50cmFjayBhbmQgTkFUIHN1
cHBvcnQgdG8KPiAgICBuZXQvb3BlbnZzd2l0Y2gvS2NvbmZpZy4KPiAKPiAyKSBNb3ZlIHRoZSBO
QVQgY29kZSB0byB0aGUgY29ycmVzcG9uZGluZyBvcGVudnN3aXRjaC9uYXQuYyBmaWxlLgo+IAo+
IEp1c3QgbXkgdHdvIGNlbnRzLgoKWWVzLCBJIHRoaW5rIHRoYXQgd291bGQgYmUgZ29vZCB0b28u
IEkgYWxzbyBmb3VuZCB0aGF0IHRoZSBkcml2ZXIKdXNlZCB0byBsb29rIGxpa2UgdGhhdCBidXQg
aXQgd2FzIGNoYW5nZWQgYXMgcGFydCBvZiBmODhmNjlkZDE3ZjEKKCJvcGVudnN3aXRjaDogUmVt
b3ZlIGNvbm50cmFjayBLY29uZmlnIG9wdGlvbi4iKS4KCglBcm5kCgpfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVu
dnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
