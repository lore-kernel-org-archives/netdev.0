From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 7/8] neigh: align nlattr properly when
	needed
Date: Tue, 26 Apr 2016 10:06:17 +0200
Message-ID: <1461657978-13360-8-git-send-email-nicolas.dichtel@6wind.com>
References: <1461657978-13360-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
 sd-y1jBWg8GRStKuXlAQpz2QA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org,
 jack-IBi9RG/b67k@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1461657978-13360-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
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

U2lnbmVkLW9mZi1ieTogTmljb2xhcyBEaWNodGVsIDxuaWNvbGFzLmRpY2h0ZWxANndpbmQuY29t
PgotLS0KIG5ldC9jb3JlL25laWdoYm91ci5jIHwgMyArKy0KIDEgZmlsZSBjaGFuZ2VkLCAyIGlu
c2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkKCmRpZmYgLS1naXQgYS9uZXQvY29yZS9uZWlnaGJv
dXIuYyBiL25ldC9jb3JlL25laWdoYm91ci5jCmluZGV4IDZhMzk1ZDQ0MDIyOC4uMjlkZDhjYzIy
YmJmIDEwMDY0NAotLS0gYS9uZXQvY29yZS9uZWlnaGJvdXIuYworKysgYi9uZXQvY29yZS9uZWln
aGJvdXIuYwpAQCAtMTg1Nyw3ICsxODU3LDggQEAgc3RhdGljIGludCBuZWlnaHRibF9maWxsX2lu
Zm8oc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IG5laWdoX3RhYmxlICp0YmwsCiAJCQluZHN0
Lm5kdHNfdGFibGVfZnVsbHMJCSs9IHN0LT50YWJsZV9mdWxsczsKIAkJfQogCi0JCWlmIChubGFf
cHV0KHNrYiwgTkRUQV9TVEFUUywgc2l6ZW9mKG5kc3QpLCAmbmRzdCkpCisJCWlmIChubGFfcHV0
XzY0Yml0KHNrYiwgTkRUQV9TVEFUUywgc2l6ZW9mKG5kc3QpLCAmbmRzdCwKKwkJCQkgIE5EVEFf
UEFEKSkKIAkJCWdvdG8gbmxhX3B1dF9mYWlsdXJlOwogCX0KIAotLSAKMi44LjEKCl9fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QK
ZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGlu
Zm8vZGV2Cg==
