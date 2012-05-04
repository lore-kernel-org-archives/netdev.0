From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH 04/15] drivers/net: Do not free an IRQ if its request
 failed
Date: Fri, 04 May 2012 22:18:34 +0100
Message-ID: <4FA447AA.7030809@linaro.org>
References: <1334867804-31942-1-git-send-email-lee.jones@linaro.org>
 <1334867804-31942-5-git-send-email-lee.jones@linaro.org>
 <4FA3E35B.3000604@linaro.org>
 <CACRpkdaB+mAmo50uSDvVcq=V9_BF01-zu2WHUU+cc2WPU1NEXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: linux@arm.linux.org.uk, linus.walleij@stericsson.com, arnd@arndb.de,
 netdev@vger.kernel.org, grant.likely@secretlab.ca, cjb@laptop.org,
 linux-arm-kernel@lists.infradead.org
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CACRpkdaB+mAmo50uSDvVcq=V9_BF01-zu2WHUU+cc2WPU1NEXA@mail.gmail.com>
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

T24gMDQvMDUvMTIgMTk6MjIsIExpbnVzIFdhbGxlaWogd3JvdGU6Cj4gT24gRnJpLCBNYXkgNCwg
MjAxMiBhdCA0OjEwIFBNLCBMZWUgSm9uZXM8bGVlLmpvbmVzQGxpbmFyby5vcmc+ICB3cm90ZToK
Pj4gT24gMTkvMDQvMTIgMjE6MzYsIExlZSBKb25lcyB3cm90ZToKPgo+Pj4gLSAgICAgICAgICAg
ICAgIGdvdG8gb3V0X2ZyZWVfaXJxOwo+Pj4gKyAgICAgICAgICAgICAgIGdvdG8gb3V0X2Rpc2Fi
bGVfcmVzb3VyY2VzOwo+Pj4gICAgICAgICB9Cj4+Pgo+Pj4gICAgICAgICByZXR2YWwgPSByZWdp
c3Rlcl9uZXRkZXYoZGV2KTsKPj4KPj4KPj4gQW55dGhpbmcgb24gdGhpcyBmcm9tIHRoZSBOZXQg
Z3V5cz8KPgo+IFRoaXMgd2FzIG1lcmdlZCBmb3IgMy40LXJjNSwgY2hlY2s6Cj4gaHR0cHM6Ly9s
a21sLm9yZy9sa21sLzIwMTIvNC8yOS8yCgpJIGFjdHVhbGx5IGZvdW5kIHRoYXQgb3V0IGEgZmV3
IGhvdXJzIGFnbyBieSBhY2NpZGVudC4KClRoYW5rcyBmb3IgbGV0dGluZyBtZSBrbm93IHRob3Vn
aC4KCktpbmQgcmVnYXJkcywKTGVlCgotLSAKTGVlIEpvbmVzCkxpbmFybyBTVC1Fcmljc3NvbiBM
YW5kaW5nIFRlYW0gTGVhZApNOiArNDQgNzcgODggNjMzIDUxNQpMaW5hcm8ub3JnIOKUgiBPcGVu
IHNvdXJjZSBzb2Z0d2FyZSBmb3IgQVJNIFNvQ3MKRm9sbG93IExpbmFybzogRmFjZWJvb2sgfCBU
d2l0dGVyIHwgQmxvZwoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KbGludXgtYXJtLWtlcm5lbCBtYWlsaW5nIGxpc3QKbGludXgtYXJtLWtlcm5lbEBsaXN0
cy5pbmZyYWRlYWQub3JnCmh0dHA6Ly9saXN0cy5pbmZyYWRlYWQub3JnL21haWxtYW4vbGlzdGlu
Zm8vbGludXgtYXJtLWtlcm5lbAo=
