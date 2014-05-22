From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/9] Documentation: devicetree: add old and
 deprecated 'fixed-link'
Date: Thu, 22 May 2014 09:47:43 -0700
Message-ID: <1400777271-32199-2-git-send-email-f.fainelli@gmail.com>
References: <1400777271-32199-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 "open list:OPEN FIRMWARE AND..." <devicetree@vger.kernel.org>,
 Florian Fainelli <f.fainelli@gmail.com>,
 Aida Mynzhasova <aida.mynzhasova@skitlab.ru>,
 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
 Richard Cochran <richardcochran@gmail.com>,
 open list <linux-kernel@vger.kernel.org>,
 Claudiu Manoil <claudiu.manoil@freescale.com>,
 Vitaly Bordug <vbordug@ru.mvista.com>, Grant Likely <grant.likely@linaro.org>,
 "open list:LINUX FOR POWERPC..." <linuxppc-dev@lists.ozlabs.org>,
 davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1400777271-32199-1-git-send-email-f.fainelli@gmail.com>
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

VXBkYXRlIHRoZSBmaXhlZC1saW5rIERldmljZSBUcmVlIGJpbmRpbmcgZG9jdW1lbnRhdGlvbiB0
byBjb250YWluCmluZm9ybWF0aW9uIGFib3V0IHRoZSBvbGQgYW5kIGRlcHJlY2F0ZWQgNS1kaWdp
dCAnZml4ZWQtbGluaycgcHJvcGVydHkuCgpTaWduZWQtb2ZmLWJ5OiBGbG9yaWFuIEZhaW5lbGxp
IDxmLmZhaW5lbGxpQGdtYWlsLmNvbT4KLS0tCkNoYW5nZXMgaW4gdjI6Ci0gZml4ZWQgdHlwb3Mg
YW5kIHNwZWxsaW5nIG1pc3Rha2VzIGFzIHNwb3R0ZWQgYnkgU2VyZ2VpCgogRG9jdW1lbnRhdGlv
bi9kZXZpY2V0cmVlL2JpbmRpbmdzL25ldC9maXhlZC1saW5rLnR4dCB8IDEyICsrKysrKysrKysr
KwogMSBmaWxlIGNoYW5nZWQsIDEyIGluc2VydGlvbnMoKykKCmRpZmYgLS1naXQgYS9Eb2N1bWVu
dGF0aW9uL2RldmljZXRyZWUvYmluZGluZ3MvbmV0L2ZpeGVkLWxpbmsudHh0IGIvRG9jdW1lbnRh
dGlvbi9kZXZpY2V0cmVlL2JpbmRpbmdzL25ldC9maXhlZC1saW5rLnR4dAppbmRleCBlOTU2ZGUx
YmU5MzUuLjgyYmY3ZTBmNDdiNiAxMDA2NDQKLS0tIGEvRG9jdW1lbnRhdGlvbi9kZXZpY2V0cmVl
L2JpbmRpbmdzL25ldC9maXhlZC1saW5rLnR4dAorKysgYi9Eb2N1bWVudGF0aW9uL2RldmljZXRy
ZWUvYmluZGluZ3MvbmV0L2ZpeGVkLWxpbmsudHh0CkBAIC0xOCw2ICsxOCwxOCBAQCBwcm9wZXJ0
aWVzOgogKiAnYXN5bS1wYXVzZScgKGJvb2xlYW4sIG9wdGlvbmFsKSwgdG8gaW5kaWNhdGUgdGhh
dCBhc3ltX3BhdXNlIHNob3VsZAogICBiZSBlbmFibGVkLgogCitPbGQsIGRlcHJlY2F0ZWQgJ2Zp
eGVkLWxpbmsnIGJpbmRpbmc6CisKKyogQSAnZml4ZWQtbGluaycgcHJvcGVydHkgaW4gdGhlIEV0
aGVybmV0IE1BQyBub2RlLCB3aXRoIDUgY2VsbHMsIG9mIHRoZQorICBmb3JtIDxhIGIgYyBkIGU+
IHdpdGggdGhlIGZvbGxvd2luZyBhY2NlcHRlZCB2YWx1ZXM6CisgIC0gYTogZW11bGF0ZWQgUEhZ
IElELCBjaG9vc2UgYW55IGJ1dCBidXQgdW5pcXVlIHRvIHRoZSBhbGwgc3BlY2lmaWVkCisgICAg
Zml4ZWQtbGlua3MsIGZyb20gMCB0byAzMQorICAtIGI6IGR1cGxleCBjb25maWd1cmF0aW9uOiAw
IGZvciBoYWxmIGR1cGxleCwgMSBmb3IgZnVsbCBkdXBsZXgKKyAgLSBjOiBsaW5rIHNwZWVkIGlu
IE1iaXRzL3NlYywgYWNjZXB0ZWQgdmFsdWVzIGFyZTogMTAsIDEwMCBhbmQgMTAwMAorICAtIGQ6
IHBhdXNlIGNvbmZpZ3VyYXRpb246IDAgZm9yIG5vIHBhdXNlLCAxIGZvciBwYXVzZQorICAtIGU6
IGFzeW1tZXRyaWMgcGF1c2UgY29uZmlndXJhdGlvbjogMCBmb3Igbm8gYXN5bW1ldHJpYyBwYXVz
ZSwgMSBmb3IKKyAgICBhc3ltbWV0cmljIHBhdXNlCisKIEV4YW1wbGU6CiAKIGV0aGVybmV0QDAg
ewotLSAKMS45LjEKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fCkxpbnV4cHBjLWRldiBtYWlsaW5nIGxpc3QKTGludXhwcGMtZGV2QGxpc3RzLm96bGFicy5v
cmcKaHR0cHM6Ly9saXN0cy5vemxhYnMub3JnL2xpc3RpbmZvL2xpbnV4cHBjLWRldg==
