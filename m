From: Thomas F Herbert <thomasfherbert-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next V12 2/3] Check for vlan ethernet types
	for 8021.q or 802.1ad
Date: Sun, 26 Jul 2015 10:52:34 -0400
Message-ID: <1437922355-3809-3-git-send-email-thomasfherbert@gmail.com>
References: <1437922355-3809-1-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, therbert-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1437922355-3809-1-git-send-email-thomasfherbert-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

U2lnbmVkLW9mZi1ieTogVGhvbWFzIEYgSGVyYmVydCA8dGhvbWFzZmhlcmJlcnRAZ21haWwuY29t
PgotLS0KIGluY2x1ZGUvbGludXgvaWZfdmxhbi5oIHwgMTcgKysrKysrKysrKysrKysrKysKIDEg
ZmlsZSBjaGFuZ2VkLCAxNyBpbnNlcnRpb25zKCspCgpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51
eC9pZl92bGFuLmggYi9pbmNsdWRlL2xpbnV4L2lmX3ZsYW4uaAppbmRleCA2N2NlNWJkLi44OGQx
YmU0IDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L2lmX3ZsYW4uaAorKysgYi9pbmNsdWRlL2xp
bnV4L2lmX3ZsYW4uaApAQCAtNjI3LDYgKzYyNywyMyBAQCBzdGF0aWMgaW5saW5lIG5ldGRldl9m
ZWF0dXJlc190IHZsYW5fZmVhdHVyZXNfY2hlY2soY29uc3Qgc3RydWN0IHNrX2J1ZmYgKnNrYiwK
IAogCXJldHVybiBmZWF0dXJlczsKIH0KKy8qKgorICogZXRoX3R5cGVfdmxhbiAtIGNoZWNrIGZv
ciB2YWxpZCB2bGFuIGV0aGVyIHR5cGUuCisgKiBAZXRoZXJ0eXBlOiBldGhlciB0eXBlIHRvIGNo
ZWNrCisgKgorICogUmV0dXJucyB0cnVlIGlmIHRoZSBldGhlciB0eXBlIGlzIGEgdmxhbiBldGhl
ciB0eXBlLgorICovCitzdGF0aWMgaW5saW5lIGJvb2wgZXRoX3R5cGVfdmxhbihfX2JlMTYgZXRo
ZXJ0eXBlKQoreworCXN3aXRjaCAoZXRoZXJ0eXBlKSB7CisJY2FzZSAoaHRvbnMoRVRIX1BfODAy
MVEpKToKKwkJcmV0dXJuIHRydWU7CisJY2FzZSAoaHRvbnMoRVRIX1BfODAyMUFEKSk6CisJCXJl
dHVybiB0cnVlOworCWRlZmF1bHQ6CisJCXJldHVybiBmYWxzZTsKKwl9Cit9CiAKIC8qKgogICog
Y29tcGFyZV92bGFuX2hlYWRlciAtIENvbXBhcmUgdHdvIHZsYW4gaGVhZGVycwotLSAKMi40LjMK
Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWls
aW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxt
YW4vbGlzdGluZm8vZGV2Cg==
