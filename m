From: Scott Wood <oss@buserror.net>
Subject: Re: [4/9] powerpc: inline ip_fast_csum()
Date: Fri, 4 Mar 2016 21:50:54 -0600
Message-ID: <20160305035054.GA5277@home.buserror.net>
References: <807dbc9449077e36752c649c09ae1c0d70e45254.1442876807.git.christophe.leroy@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
 netdev@vger.kernel.org, scottwood@freescale.com, linuxppc-dev@lists.ozlabs.org
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <807dbc9449077e36752c649c09ae1c0d70e45254.1442876807.git.christophe.leroy@c-s.fr>
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

T24gVHVlLCBTZXAgMjIsIDIwMTUgYXQgMDQ6MzQ6MjVQTSArMDIwMCwgQ2hyaXN0b3BoZSBMZXJv
eSB3cm90ZToKPiBAQCAtMTM3LDYgKzEzMCw0NSBAQCBzdGF0aWMgaW5saW5lIF9fd3N1bSBjc3Vt
X2FkZChfX3dzdW0gY3N1bSwgX193c3VtIGFkZGVuZCkKPiAgI2VuZGlmCj4gIH0KPiAgCj4gKy8q
Cj4gKyAqIFRoaXMgaXMgYSB2ZXJzaW9uIG9mIGlwX2NvbXB1dGVfY3N1bSgpIG9wdGltaXplZCBm
b3IgSVAgaGVhZGVycywKPiArICogd2hpY2ggYWx3YXlzIGNoZWNrc3VtIG9uIDQgb2N0ZXQgYm91
bmRhcmllcy4gIGlobCBpcyB0aGUgbnVtYmVyCj4gKyAqIG9mIDMyLWJpdCB3b3JkcyBhbmQgaXMg
YWx3YXlzID49IDUuCj4gKyAqLwo+ICtzdGF0aWMgaW5saW5lIF9fd3N1bSBpcF9mYXN0X2NzdW1f
bm9mb2xkKGNvbnN0IHZvaWQgKmlwaCwgdW5zaWduZWQgaW50IGlobCkKPiArewo+ICsJdTMyICpw
dHIgPSAodTMyICopaXBoICsgMTsKCmNvbnN0PwoKPiArI2lmZGVmIF9fcG93ZXJwYzY0X18KPiAr
CXVuc2lnbmVkIGludCBpOwo+ICsJdTY0IHMgPSAqKF9fZm9yY2UgdTMyICopaXBoOwoKY29uc3Q/
CldoeSBfX2ZvcmNlPwoKPiArCXMgKz0gKHMgPj4gMzIpOwo+ICsJcmV0dXJuIChfX2ZvcmNlIF9f
d3N1bSlzOwo+ICsKPiArI2Vsc2UKPiArCV9fd3N1bSBzdW0sIHRtcDsKPiArCj4gKwlhc20oIm10
Y3RyICUzOyIKPiArCSAgICAiYWRkYyAlMCwlNCwlNTsiCj4gKwkgICAgIjE6bHd6dSAlMSwgNCgl
Mik7Igo+ICsJICAgICJhZGRlICUwLCUwLCUxOyIKPiArCSAgICAiYmRueiAxYjsiCj4gKwkgICAg
ImFkZHplICUwLCUwOyIKPiArCSAgICA6ICI9ciIoc3VtKSwgIj1yIih0bXApLCAiK2IiKHB0cikK
PiArCSAgICA6ICJyIihpaGwgLSAyKSwgInIiKCoodTMyICopaXBoKSwgInIiKCpwdHIpCj4gKwkg
ICAgOiAiY3RyIiwgInhlciIsICJtZW1vcnkiKTsKClNwYWNlIGJldHdlZW4gIiBhbmQgKApTcGFj
ZSBhZnRlciA6CmNvbnN0IGluIGNhc3QKCkkndmUgZml4ZWQgdGhlc2UgdXAgd2hpbGUgYXBwbHlp
bmcuCgotU2NvdHQKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X18KTGludXhwcGMtZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9y
ZwpodHRwczovL2xpc3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2
