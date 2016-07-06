From: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Subject: [PATCH net-next v11 2/6] gre: unset mac header for
	non-TEB packets received by ipgre device
Date: Wed,  6 Jul 2016 19:59:52 +0200
Message-ID: <1467827996-32547-3-git-send-email-simon.horman@netronome.com>
References: <1467827996-32547-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1467827996-32547-1-git-send-email-simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
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

dW5zZXQgcmF0aGVyIHRoYW4gcmVzZXQgbWFjaCBoZWFkZXIgZm9yIG5vbi1URUIgcGFja2V0cyBy
ZWNlaXZlZCBieSBhbgppcGdyZSBkZXZpY2UuICBUaGlzIGFsbG93cyBza2JfdHJhbnNwb3J0X2hl
YWRlcl93YXNfc2V0IHRvIGJlIHN1YnNlcXVlbnRseQp1c2VkIHRvIGRpZmZlcmVudGlhdGUgVEVC
IGFuZCBub24tVEVCIHBhY2tldHMgcmVjaWV2ZWQgb24gYW4gaXBncmUgZGV2aWNlLgoKU2lnbmVk
LW9mZi1ieTogU2ltb24gSG9ybWFuIDxzaW1vbi5ob3JtYW5AbmV0cm9ub21lLmNvbT4KLS0tCnYx
MQoqIE5ldyBwYXRjaAotLS0KIG5ldC9pcHY0L2lwX2dyZS5jIHwgMiArKwogMSBmaWxlIGNoYW5n
ZWQsIDIgaW5zZXJ0aW9ucygrKQoKZGlmZiAtLWdpdCBhL25ldC9pcHY0L2lwX2dyZS5jIGIvbmV0
L2lwdjQvaXBfZ3JlLmMKaW5kZXggNWIxNDgxYmUwMjgyLi4zMzBkNThlOWM1MjMgMTAwNjQ0Ci0t
LSBhL25ldC9pcHY0L2lwX2dyZS5jCisrKyBiL25ldC9pcHY0L2lwX2dyZS5jCkBAIC0yODMsNiAr
MjgzLDggQEAgc3RhdGljIGludCBfX2lwZ3JlX3JjdihzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBjb25z
dCBzdHJ1Y3QgdG5sX3B0a19pbmZvICp0cGksCiAKIAkJaWYgKHR1bm5lbC0+ZGV2LT50eXBlICE9
IEFSUEhSRF9OT05FKQogCQkJc2tiX3BvcF9tYWNfaGVhZGVyKHNrYik7CisJCWVsc2UgaWYgKHRw
aS0+cHJvdG8gIT0gaHRvbnMoRVRIX1BfVEVCKSkKKwkJCXNrYl91bnNldF9tYWNfaGVhZGVyKHNr
Yik7CiAJCWVsc2UKIAkJCXNrYl9yZXNldF9tYWNfaGVhZGVyKHNrYik7CiAJCWlmICh0dW5uZWwt
PmNvbGxlY3RfbWQpIHsKLS0gCjIuNy4wLnJjMy4yMDcuZzBhYzUzNDQKCl9fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9w
ZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2
Cg==
