From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: RFC  [PATCH] iproute2:  temporary solution to fix xt breakage
Date: Mon, 17 Dec 2012 07:30:41 -0500
Message-ID: <50CF1071.1050405@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010503080200020409080507"
Cc: Hasan Chowdhury <shemonc@gmail.com>,
	Jan Engelhardt <jengelh@inai.de>,
	Yury Stankevich <urykhy@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:38905 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703Ab2LQMap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 07:30:45 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so9140649ieb.19
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2012 04:30:44 -0800 (PST)
In-Reply-To: <50CE3203.9080007@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010503080200020409080507
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 12-12-16 03:41 PM, Jamal Hadi Salim wrote:
>
> There is an "intermediate solution" from Hasan which doesnt require
> the kernel change. It changes the kernel endpoint to "ipt". I am
> conflicted because it is a quick hack while otoh forcing people to
> upgrade kernel is a usability issue.
>


Attached. Author is Hasan - I didnt sign it because i am looking for
feedback and i find it distasteful but it solves the problem.
This is needed until we have a proper fix in the kernel propagated.
Once that kernel change is ubiquitous this change is noise and a
maintanance pain. I am making it hard to even turn it on
(i.e someone knowledgeable will have to compile with CONFIG_XT_HACK)

cheers,
jamal



--------------010503080200020409080507
Content-Type: text/plain; charset=UTF-8;
 name="p1"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="p1"

ZGlmZiAtLWdpdCBhL3RjL21fYWN0aW9uLmMgYi90Yy9tX2FjdGlvbi5jCmluZGV4IDFmZTI0
MzEuLmZhOWE3YzggMTAwNjQ0Ci0tLSBhL3RjL21fYWN0aW9uLmMKKysrIGIvdGMvbV9hY3Rp
b24uYwpAQCAtMjA5LDEwICsyMDksMTcgQEAgZG9uZTA6CiAKIAkJCXRhaWwgPSBOTE1TR19U
QUlMKG4pOwogCQkJYWRkYXR0cl9sKG4sIE1BWF9NU0csICsrcHJpbywgTlVMTCwgMCk7CisJ
CQkvKlhYWDogaGFjayB0byB3b3JrIGFyb3VuZCBvbGQga2VybmVscywgbmV3ZXIgeHRhYmxl
cyAqLworI2lmZGVmIENPTkZJR19YVF9IQUNLCisJCQlpZiAoc3RybmNtcChrLCJ4dCIsMik9
PTApCisJCQkJYWRkYXR0cl9sKG4sIE1BWF9NU0csIFRDQV9BQ1RfS0lORCwgImlwdCIgLCBz
dHJsZW4oImlwdCIpICsgMSk7CisJCQllbHNlIAorCQkJCWFkZGF0dHJfbChuLCBNQVhfTVNH
LCBUQ0FfQUNUX0tJTkQsIGssIHN0cmxlbihrKSArIDEpOworI2Vsc2UKIAkJCWFkZGF0dHJf
bChuLCBNQVhfTVNHLCBUQ0FfQUNUX0tJTkQsIGssIHN0cmxlbihrKSArIDEpOworI2VuZGlm
CiAKIAkJCXJldCA9IGEtPnBhcnNlX2FvcHQoYSwmYXJnYywgJmFyZ3YsIFRDQV9BQ1RfT1BU
SU9OUywgbik7Ci0KIAkJCWlmIChyZXQgPCAwKSB7CiAJCQkJZnByaW50ZihzdGRlcnIsImJh
ZCBhY3Rpb24gcGFyc2luZ1xuIik7CiAJCQkJZ290byBiYWRfdmFsOwpAQCAtMjU5LDcgKzI2
NiwxNSBAQCB0Y19wcmludF9vbmVfYWN0aW9uKEZJTEUgKiBmLCBzdHJ1Y3QgcnRhdHRyICph
cmcpCiAJfQogCiAKKwkvKlhYWDogaGFjayB0byB3b3JrIGFyb3VuZCBvbGQga2VybmVscywg
bmV3ZXIgeHRhYmxlcyAqLworI2lmZGVmIENPTkZJR19YVF9IQUNLCisJaWYgKHN0cmNtcChS
VEFfREFUQSh0YltUQ0FfQUNUX0tJTkRdKSwgImlwdCIpPT0wKQorCQlhID0gZ2V0X2FjdGlv
bl9raW5kKCJ4dCIpOworCWVsc2UgCisJCWEgPSBnZXRfYWN0aW9uX2tpbmQoUlRBX0RBVEEo
dGJbVENBX0FDVF9LSU5EXSkpOworI2Vsc2UKIAlhID0gZ2V0X2FjdGlvbl9raW5kKFJUQV9E
QVRBKHRiW1RDQV9BQ1RfS0lORF0pKTsKKyNlbmRpZgogCWlmIChOVUxMID09IGEpCiAJCXJl
dHVybiBlcnI7CiAK
--------------010503080200020409080507--
