From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/9] Documentation: devicetree: add old and
 deprecated 'fixed-link'
Date: Mon, 19 May 2014 17:56:16 -0700
Message-ID: <1400547384-11363-2-git-send-email-f.fainelli@gmail.com>
References: <1400547384-11363-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Mark Rutland <mark.rutland@arm.com>,
 "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
 Paul Mackerras <paulus@samba.org>, Florian Fainelli <f.fainelli@gmail.com>,
 Claudiu Manoil <claudiu.manoil@freescale.com>,
 Grant Likely <grant.likely@linaro.org>,
 "open list:OPEN FIRMWARE AND..." <devicetree@vger.kernel.org>,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Richard Cochran <richardcochran@gmail.com>, Rob Herring <robh+dt@kernel.org>,
 Aida Mynzhasova <aida.mynzhasova@skitlab.ru>,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
 Randy Dunlap <rdunlap@infradead.org>, open list <linux-kernel@vger.kernel.org>,
 davem@davemlof.net, Vitaly Bordug <vbordug@ru.mvista.com>,
 Kumar Gala <galak@codeaurora.org>,
 "open list:LINUX FOR POWERPC..." <linuxppc-dev@lists.ozlabs.org>,
 "David S.
To: netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1400547384-11363-1-git-send-email-f.fainelli@gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

VXBkYXRlIHRoZSBmaXhlZC1saW5rIERldmljZSBUcmVlIGJpbmRpbmcgZG9jdW1lbnRhdGlvbiB0
byBjb250YWluCmluZm9ybWF0aW9uIGFib3V0IHRoZSBvbGQgYW5kIGRlcHJlY2F0ZWQgNS1kaWdp
dCAnZml4ZWQtbGluaycgcHJvcGVydHkuCgpTaWduZWQtb2ZmLWJ5OiBGbG9yaWFuIEZhaW5lbGxp
IDxmLmZhaW5lbGxpQGdtYWlsLmNvbT4KLS0tCiBEb2N1bWVudGF0aW9uL2RldmljZXRyZWUvYmlu
ZGluZ3MvbmV0L2ZpeGVkLWxpbmsudHh0IHwgMTIgKysrKysrKysrKysrCiAxIGZpbGUgY2hhbmdl
ZCwgMTIgaW5zZXJ0aW9ucygrKQoKZGlmZiAtLWdpdCBhL0RvY3VtZW50YXRpb24vZGV2aWNldHJl
ZS9iaW5kaW5ncy9uZXQvZml4ZWQtbGluay50eHQgYi9Eb2N1bWVudGF0aW9uL2RldmljZXRyZWUv
YmluZGluZ3MvbmV0L2ZpeGVkLWxpbmsudHh0CmluZGV4IGU5NTZkZTFiZTkzNS4uMzRhOTkxZWIy
MTNmIDEwMDY0NAotLS0gYS9Eb2N1bWVudGF0aW9uL2RldmljZXRyZWUvYmluZGluZ3MvbmV0L2Zp
eGVkLWxpbmsudHh0CisrKyBiL0RvY3VtZW50YXRpb24vZGV2aWNldHJlZS9iaW5kaW5ncy9uZXQv
Zml4ZWQtbGluay50eHQKQEAgLTE4LDYgKzE4LDE4IEBAIHByb3BlcnRpZXM6CiAqICdhc3ltLXBh
dXNlJyAoYm9vbGVhbiwgb3B0aW9uYWwpLCB0byBpbmRpY2F0ZSB0aGF0IGFzeW1fcGF1c2Ugc2hv
dWxkCiAgIGJlIGVuYWJsZWQuCiAKK09sZCwgZGVwcmVjYXRlZCAnZml4ZWQtbGluaycgYmluZGlu
ZzoKKworKiBBICdmaXhlZC1saW5rJyBwcm9wZXJ0eSBpbiB0aGUgRXRoZXJuZXQgTUFDIG5vZGUs
IHdpdGggNSBjZWxscywgb2YgdGhlCisgIGZvcm0gPGEgYiBjIGQgZT4gd2l0aCB0aGUgZm9sbG93
aW5nIGFjY2VwdGVkIHZhbHVlczoKKyAgLSBhOiBlbXVsYXRlZCBwaHkgaWQsIGNob29zZSBhbnkg
YnV0IGJ1dCB1bmlxdWUgdG8gdGhlIGFsbCBzcGVjaWZpZWQKKyAgICBmaXhlZC1saW5rcywgZnJv
bSAwIHRvIDMxCisgIC0gYjogZHVwbGV4IGNvbmZpZ3VyYXRpb246IDAgZm9yIGhhbGYgZHVwbGV4
LCAxIGZvciBmdWxsIGR1cGxleAorICAtIGM6IGxpbmsgc3BlZWQgaW4gTWJpdHMvc2VjLCBhY2Nl
cHRlZCB2YWx1ZXMgYXJlOiAxMCwgMTAwIGFuZCAxMDAwCisgIC0gZDogcGF1c2UgY29uZmlndXJh
dGlvbjogMCBmb3Igbm8gcGF1c2UsIDEgZm9yIHBhdXNlCisgIC0gZTogYXN5bWV0cmljIHBhdXNl
IGNvbmZpZ3VyYXRpb246IDAgZm9yIG5vIGFzeW1ldHJpYyBwYXVzZSwgMSBmb3IgYXN5bWV0cmlj
CisgICAgcGF1c2UKKwogRXhhbXBsZToKIAogZXRoZXJuZXRAMCB7Ci0tIAoxLjkuMQoKX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMtZGV2IG1h
aWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xpc3RzLm96
bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2
