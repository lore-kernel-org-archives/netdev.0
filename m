From: "Jeff Kirsher" <tarbal@gmail.com>
Subject: Re: [PATCH] ethtool v4: add autoneg advertise feature
Date: Thu, 24 Aug 2006 09:12:56 -0700
Message-ID: <9929d2390608240912l14ea45c2l428d3eab6ce573b@mail.gmail.com>
References: <1551EAE59135BE47B544934E30FC4FC093FAA2@NT-IRVA-0751.brcm.ad.broadcom.com>
	 <44EDCCE2.3030408@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_148083_15842680.1156435976384"
Cc: "Michael Chan" <mchan@broadcom.com>,
	"Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>,
	"John Ronciak" <john.ronciak@intel.com>,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:35128 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1030328AbWHXQM6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 12:12:58 -0400
Received: by ug-out-1314.google.com with SMTP id m3so550830ugc
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2006 09:12:56 -0700 (PDT)
To: "Auke Kok" <auke-jan.h.kok@intel.com>
In-Reply-To: <44EDCCE2.3030408@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_148083_15842680.1156435976384
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 8/24/06, Auke Kok <auke-jan.h.kok@intel.com> wrote:
> the patch doesn't remove the old method, it merely adds a second path to the
> speed/duplex setting. Using the "old" syntax will still work.
>
> Cheers,
>
> Auke
>

Actually, I did remove the functionality of the "old" method.  The
attached patch revises that.  I will also send this revised patch
inline and not as an attachment.

-- 
Cheers,
Jeff

------=_Part_148083_15842680.1156435976384
Content-Type: text/x-patch; name="autoneg_advertise.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="autoneg_advertise.patch"
X-Attachment-Id: f_er9c419j

ZXRodG9vbCB2NDogYWRkIGF1dG9uZWcgYWR2ZXJ0aXNlIGZlYXR1cmUKCkZyb206IEplZmYgS2ly
c2hlciA8amVmZnJleS50LmtpcnNoZXJAaW50ZWwuY29tPgoKYWRkcyB0aGUgYWJpbGl0eSB0byBj
aGFuZ2UgdGhlIGFkdmVydGlzZWQgc3BlZWQgYW5kIGR1cGxleCBmb3IgYSBuZXR3b3JrIGludGVy
ZmFjZS4gIFByZXZpb3VzbHksIGEgbmV0d29yayBpbnRlcmZhY2Ugd2FzIG9ubHkgYWJsZSB0byBh
ZHZlcnRpc2UgYWxsIHN1cHBvcnRlZCBzcGVlZCdzIGFuZCBkdXBsZXgncywgb3Igb25lIGluZGl2
aWR1YWwgc3BlZWQgYW5kIGR1cGxleC4gIFRoZSBmZWF0dXJlIGFsbG93cyB0aGUgdXNlciB0byBj
aG9vc2Ugd2hpY2ggc3VwcG9ydGVkIHNwZWVkJ3MgYW5kIGR1cGxleCdzIHRvIGFkdmVydGlzZSBi
eSB1c2luZyB0aGUgaGV4IHZhbHVlLgotLS0KCiBldGh0b29sLmMgfCAgIDEyICsrKysrKysrKysr
LQogMSBmaWxlcyBjaGFuZ2VkLCAxMSBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9ucygtKQoKZGlm
ZiAtLWdpdCBhL2V0aHRvb2wuYyBiL2V0aHRvb2wuYwppbmRleCA4N2UyMmFiLi5iN2YxODlhIDEw
MDY0NAotLS0gYS9ldGh0b29sLmMKKysrIGIvZXRodG9vbC5jCkBAIC05OSw2ICs5OSw3IEBAIHN0
YXRpYyBzdHJ1Y3Qgb3B0aW9uIHsKIAkJIgkJWyBkdXBsZXggaGFsZnxmdWxsIF1cbiIKIAkJIgkJ
WyBwb3J0IHRwfGF1aXxibmN8bWlpfGZpYnJlIF1cbiIKIAkJIgkJWyBhdXRvbmVnIG9ufG9mZiBd
XG4iCisJCSIJCVsgYWR2ZXJ0aXNlICUleCBdXG4iCiAJCSIJCVsgcGh5YWQgJSVkIF1cbiIKIAkJ
IgkJWyB4Y3ZyIGludGVybmFsfGV4dGVybmFsIF1cbiIKIAkJIgkJWyB3b2wgcHx1fG18YnxhfGd8
c3xkLi4uIF1cbiIKQEAgLTU0OSw2ICs1NTAsMTUgQEAgc3RhdGljIHZvaWQgcGFyc2VfY21kbGlu
ZShpbnQgYXJnYywgY2hhcgogCQkJCQlzaG93X3VzYWdlKDEpOwogCQkJCX0KIAkJCQlicmVhazsK
KwkJCX0gZWxzZSBpZiAoIXN0cmNtcChhcmdwW2ldLCAiYWR2ZXJ0aXNlIikpIHsKKwkJCQlnc2V0
X2NoYW5nZWQgPSAxOworCQkJCWkgKz0gMTsKKwkJCQlpZiAoaSA+PSBhcmdjKQorCQkJCQlzaG93
X3VzYWdlKDEpOworCQkJCWFkdmVydGlzaW5nX3dhbnRlZCA9IHN0cnRvbChhcmdwW2ldLCBOVUxM
LCAxNik7CisJCQkJaWYgKGFkdmVydGlzaW5nX3dhbnRlZCA8IDApCisJCQkJCXNob3dfdXNhZ2Uo
MSk7CisJCQkJYnJlYWs7CiAJCQl9IGVsc2UgaWYgKCFzdHJjbXAoYXJncFtpXSwgInBoeWFkIikp
IHsKIAkJCQlnc2V0X2NoYW5nZWQgPSAxOwogCQkJCWkgKz0gMTsKQEAgLTYwMSw3ICs2MTEsNyBA
QCBzdGF0aWMgdm9pZCBwYXJzZV9jbWRsaW5lKGludCBhcmdjLCBjaGFyCiAJCX0KIAl9CiAKLQlp
ZiAoYXV0b25lZ193YW50ZWQgPT0gQVVUT05FR19FTkFCTEUpeworCWlmICgoYXV0b25lZ193YW50
ZWQgPT0gQVVUT05FR19FTkFCTEUpICYmIChhZHZlcnRpc2luZ193YW50ZWQgPCAwKSkgewogCQlp
ZiAoc3BlZWRfd2FudGVkID09IFNQRUVEXzEwICYmIGR1cGxleF93YW50ZWQgPT0gRFVQTEVYX0hB
TEYpCiAJCQlhZHZlcnRpc2luZ193YW50ZWQgPSBBRFZFUlRJU0VEXzEwYmFzZVRfSGFsZjsKIAkJ
ZWxzZSBpZiAoc3BlZWRfd2FudGVkID09IFNQRUVEXzEwICYmCg==
------=_Part_148083_15842680.1156435976384--
