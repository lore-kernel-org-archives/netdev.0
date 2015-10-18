From: Thomas F Herbert <thomasfherbert-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next V17 2/3] Check for vlan ethernet types
	for 8021.q or 802.1ad
Date: Sat, 17 Oct 2015 21:12:27 -0400
Message-ID: <1445130748-27671-3-git-send-email-thomasfherbert@gmail.com>
References: <1445130748-27671-1-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, therbert-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1445130748-27671-1-git-send-email-thomasfherbert-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
PgotLS0KIGluY2x1ZGUvbGludXgvaWZfdmxhbi5oIHwgMTYgKysrKysrKysrKysrKysrKwogMSBm
aWxlIGNoYW5nZWQsIDE2IGluc2VydGlvbnMoKykKCmRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4
L2lmX3ZsYW4uaCBiL2luY2x1ZGUvbGludXgvaWZfdmxhbi5oCmluZGV4IDY3Y2U1YmQuLmQyNDk0
YjUgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvaWZfdmxhbi5oCisrKyBiL2luY2x1ZGUvbGlu
dXgvaWZfdmxhbi5oCkBAIC02MjcsNiArNjI3LDIyIEBAIHN0YXRpYyBpbmxpbmUgbmV0ZGV2X2Zl
YXR1cmVzX3Qgdmxhbl9mZWF0dXJlc19jaGVjayhjb25zdCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAog
CiAJcmV0dXJuIGZlYXR1cmVzOwogfQorLyoqCisgKiBldGhfdHlwZV92bGFuIC0gY2hlY2sgZm9y
IHZhbGlkIHZsYW4gZXRoZXIgdHlwZS4KKyAqIEBldGhlcnR5cGU6IGV0aGVyIHR5cGUgdG8gY2hl
Y2sKKyAqCisgKiBSZXR1cm5zIHRydWUgaWYgdGhlIGV0aGVyIHR5cGUgaXMgYSB2bGFuIGV0aGVy
IHR5cGUuCisgKi8KK3N0YXRpYyBpbmxpbmUgYm9vbCBldGhfdHlwZV92bGFuKF9fYmUxNiBldGhl
cnR5cGUpCit7CisJc3dpdGNoIChldGhlcnR5cGUpIHsKKwljYXNlIGh0b25zKEVUSF9QXzgwMjFR
KToKKwljYXNlIGh0b25zKEVUSF9QXzgwMjFBRCk6CisJCXJldHVybiB0cnVlOworCWRlZmF1bHQ6
CisJCXJldHVybiBmYWxzZTsKKwl9Cit9CiAKIC8qKgogICogY29tcGFyZV92bGFuX2hlYWRlciAt
IENvbXBhcmUgdHdvIHZsYW4gaGVhZGVycwotLSAKMi40LjMKCl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dp
dGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
