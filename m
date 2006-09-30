From: "Olivier Crameri" <olivier.crameri@gmail.com>
Subject: Re: Offloading features in VLAN interfaces
Date: Fri, 29 Sep 2006 17:25:35 -0700
Message-ID: <b54af0b00609291725t55ac0a84pf86525ef0a31f44e@mail.gmail.com>
References: <b54af0b00609291721u16acb2f1ma918adec9b2e782b@mail.gmail.com>
Reply-To: olivier.crameri@epfl.ch
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_27577_1373493.1159575935707"
Cc: "Yoshio Turner" <yoshiotu@hpl.hp.com>,
	"Santos, Jose Renato G" <joserenato.santos@hp.com>,
	"Janakiraman, John" <john.janakiraman@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:63255 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932379AbWI3AZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 20:25:37 -0400
Received: by ug-out-1314.google.com with SMTP id o38so328168ugd
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 17:25:36 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <b54af0b00609291721u16acb2f1ma918adec9b2e782b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_27577_1373493.1159575935707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Same thing but with the patch this time.

Sorry about that,
Olivier Crameri

On 9/29/06, Olivier Crameri <olivier.crameri@gmail.com> wrote:
> Hi,
>
> after running some experiments, we realised that using VLAN support in
> Linux caused some overhead. It turned out to be that the offloading
> features of our NIC (tso, sg, checksum offloading) were not beeing
> used.
>
> After digging a little bit in the code, we realised that the VLAN code
> did not set the features parameter of the net_device structure for the
> virtual interface. Attached is a patch with a suggested solution to
> this problem.
>
> Please let us know if this is an acceptable patch.
>
> Thanks,
> Olivier Crameri, HP Labs
>

------=_Part_27577_1373493.1159575935707
Content-Type: application/octet-stream; name=vlan.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_esp9ja5s
Content-Disposition: attachment; filename="vlan.patch"

LS0tIG5ldC84MDIxcS92bGFuLmMub3JpZwkyMDA2LTA5LTI5IDE2OjIwOjAxLjAwMDAwMDAwMCAt
MDcwMAorKysgbmV0LzgwMjFxL3ZsYW4uYwkyMDA2LTA5LTI5IDE3OjE2OjMxLjAwMDAwMDAwMCAt
MDcwMApAQCAtMTAsNyArMTAsOSBAQAogICogICAgICAgICAgICAgIEZpeCBmb3IgcGFja2V0IGNh
cHR1cmUgLSBOaWNrIEVnZ2xlc3RvbiA8bmlja0BkY2NpbmMuY29tPjsKICAqCQlBZGQgSFcgYWNj
ZWxlcmF0aW9uIGhvb2tzIC0gRGF2aWQgUy4gTWlsbGVyIDxkYXZlbUByZWRoYXQuY29tPjsKICAq
CQlDb3JyZWN0IGFsbCB0aGUgbG9ja2luZyAtIERhdmlkIFMuIE1pbGxlciA8ZGF2ZW1AcmVkaGF0
LmNvbT47Ci0gKgkJVXNlIGhhc2ggdGFibGUgZm9yIFZMQU4gZ3JvdXBzIC0gRGF2aWQgUy4gTWls
bGVyIDxkYXZlbUByZWRoYXQuY29tPgorICoJCVVzZSBoYXNoIHRhYmxlIGZvciBWTEFOIGdyb3Vw
cyAtIERhdmlkIFMuIE1pbGxlciA8ZGF2ZW1AcmVkaGF0LmNvbT47CisgKgkJQWR2ZXJ0aXNlIHJl
YWwgZGV2aWNlJ3MgZmVhdHVyZXMgLSBPbGl2aWVyIENyYW1lcmksIEhld2xldHQtUGFja2FyZCAK
KyAqCQk8b2xpdmllci5jcmFtZXJpQGVwZmwuY2g+CiAgKgogICoJCVRoaXMgcHJvZ3JhbSBpcyBm
cmVlIHNvZnR3YXJlOyB5b3UgY2FuIHJlZGlzdHJpYnV0ZSBpdCBhbmQvb3IKICAqCQltb2RpZnkg
aXQgdW5kZXIgdGhlIHRlcm1zIG9mIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZQpAQCAt
NTEyLDYgKzUxNCwxNSBAQCBzdGF0aWMgc3RydWN0IG5ldF9kZXZpY2UgKnJlZ2lzdGVyX3ZsYW5f
CiAJfQogCW5ld19kZXYtPmhhcmRfaGVhZGVyX3BhcnNlID0gcmVhbF9kZXYtPmhhcmRfaGVhZGVy
X3BhcnNlOwogCisJLyogQWR2ZXJ0aXNlIHRoZSBzYW1lIG9mZmxvYWRpbmcgZmVhdHVyZXMgdGhh
biB0aGUgcmVhbCBkZXZpY2UgKi8KKwluZXdfZGV2LT5mZWF0dXJlcyA9IHJlYWxfZGV2LT5mZWF0
dXJlcyAmIAorCQkJCShORVRJRl9GX0lQX0NTVU0gfAorCQkJCSBORVRJRl9GX05PX0NTVU0gfAor
CQkJCSBORVRJRl9GX0hXX0NTVU0gfAorCQkJCSBORVRJRl9GX1NHIHwKKwkJCQkgTkVUSUZfRl9G
UkFHTElTVCB8CisJCQkJIE5FVElGX0ZfVFNPICk7CisJCiAJVkxBTl9ERVZfSU5GTyhuZXdfZGV2
KS0+dmxhbl9pZCA9IFZMQU5fSUQ7IC8qIDEgdGhyb3VnaCBWTEFOX1ZJRF9NQVNLICovCiAJVkxB
Tl9ERVZfSU5GTyhuZXdfZGV2KS0+cmVhbF9kZXYgPSByZWFsX2RldjsKIAlWTEFOX0RFVl9JTkZP
KG5ld19kZXYpLT5kZW50ID0gTlVMTDsKQEAgLTY2Myw2ICs2NzQsMjMgQEAgc3RhdGljIGludCB2
bGFuX2RldmljZV9ldmVudChzdHJ1Y3Qgbm90aQogCQkJCWJyZWFrOwogCQl9CiAJCWJyZWFrOwor
CQorCWNhc2UgTkVUREVWX0ZFQVRfQ0hBTkdFOgorCQkvKiBQcm9wYWdhdGUgZmVhdHVyZSBjaGFu
Z2VzIHRvIFZMQU4gZGV2aWNlcyAqLworCQlmb3IgKGkgPSAwOyBpIDwgVkxBTl9HUk9VUF9BUlJB
WV9MRU47IGkrKykgeworCQkJdmxhbmRldiA9IGdycC0+dmxhbl9kZXZpY2VzW2ldOworCQkJaWYg
KCF2bGFuZGV2KQorCQkJCWNvbnRpbnVlOworCQkJdmxhbmRldi0+ZmVhdHVyZXMgPSBkZXYtPmZl
YXR1cmVzICYgKCAKKwkJCQkJTkVUSUZfRl9JUF9DU1VNIHwKKwkJCQkgCU5FVElGX0ZfTk9fQ1NV
TSB8CisJCQkJIAlORVRJRl9GX0hXX0NTVU0gfAorCQkJCSAJTkVUSUZfRl9TRyB8CisJCQkJIAlO
RVRJRl9GX0ZSQUdMSVNUIHwKKwkJCQkgCU5FVElGX0ZfVFNPICk7CisJCX0KKwkJYnJlYWs7CisK
IAl9OwogCiBvdXQ6Cg==
------=_Part_27577_1373493.1159575935707--
