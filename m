From: "Jaswinder Singh Rajput" <jaswinderlinux@gmail.com>
Subject: Re: 2.6.29-rc1: Reported regressions from 2.6.28
Date: Sun, 11 Jan 2009 19:16:32 +0530
Message-ID: <3f9a31f40901110546h4c069b5dx9726a0fbf8caf5a1@mail.gmail.com>
References: <XU-8icArWLM.A.UpG.8GfaJB@chimera>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_265887_17688763.1231681592975"
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Adrian Bunk" <bunk@kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Natalie Protasevich" <protasnb@gmail.com>,
	"Kernel Testers List" <kernel-testers@vger.kernel.org>,
	"Network Development" <netdev@vger.kernel.org>,
	"Linux ACPI" <linux-acpi@vger.kernel.org>,
	"Linux PM List" <linux-pm@lists.linux-foundation.org>,
	"Linux SCSI List" <linux-scsi@vger.kernel.org>,
	"Ingo Molnar" <mingo@elte.hu>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <XU-8icArWLM.A.UpG.8GfaJB@chimera>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_265887_17688763.1231681592975
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Sun, Jan 11, 2009 at 4:42 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>
> Regressions with patches
> ------------------------
>
> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=12428
> Subject         : Build error on latest git
> Submitter       : Petr Titera <P.Titera@century.cz>
> Date            : 2009-01-11 9:49 (1 days old)
> References      : http://marc.info/?l=linux-kernel&m=123166856318712&w=4
> Handled-By      : Petr Titera <P.Titera@century.cz>
> Patch           : http://marc.info/?l=linux-kernel&m=123167509024996&w=4
>
>

This is a wrong fix, asm/smp.h should only be included when CONFIG_SMP
is defined.

I am still in the process of cleaning non-smp data from asm/smp.h for x86

Attach patch is the solution for the time being

Ingo, can you please put this in urgent queue.

Thanks
--
JSR

------=_Part_265887_17688763.1231681592975
Content-Type: application/octet-stream;
 name=0001-x86-mpparse.c-fix-compilation-error.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fptr9frv0
Content-Disposition: attachment;
 filename=0001-x86-mpparse.c-fix-compilation-error.patch

RnJvbSA4ZTdiMGQ0ZWE0NDU4Zjk5NjZjNTQ1NTFhYzBiZDc5YjM0ZDVmOTM1IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBKYXN3aW5kZXIgU2luZ2ggUmFqcHV0IDxqYXN3aW5kZXJyYWpw
dXRAZ21haWwuY29tPgpEYXRlOiBTdW4sIDExIEphbiAyMDA5IDE4OjMwOjM0ICswNTMwClN1Ympl
Y3Q6IFtQQVRDSF0geDg2OiBtcHBhcnNlLmMgZml4IGNvbXBpbGF0aW9uIGVycm9yCgpJbXBhY3Q6
IGZpeCBjb21waWxhdGlvbiBlcnJvcgoKU2lnbmVkLW9mZi1ieTogSmFzd2luZGVyIFNpbmdoIFJh
anB1dCA8amFzd2luZGVycmFqcHV0QGdtYWlsLmNvbT4KLS0tCiBhcmNoL3g4Ni9rZXJuZWwvbXBw
YXJzZS5jIHwgICAgMSArCiAxIGZpbGVzIGNoYW5nZWQsIDEgaW5zZXJ0aW9ucygrKSwgMCBkZWxl
dGlvbnMoLSkKCmRpZmYgLS1naXQgYS9hcmNoL3g4Ni9rZXJuZWwvbXBwYXJzZS5jIGIvYXJjaC94
ODYva2VybmVsL21wcGFyc2UuYwppbmRleCA4Mzg1ZDRlLi43OWRhZTYwIDEwMDY0NAotLS0gYS9h
cmNoL3g4Ni9rZXJuZWwvbXBwYXJzZS5jCisrKyBiL2FyY2gveDg2L2tlcm5lbC9tcHBhcnNlLmMK
QEAgLTI3LDYgKzI3LDcgQEAKICNpbmNsdWRlIDxhc20vZTgyMC5oPgogI2luY2x1ZGUgPGFzbS90
cmFtcG9saW5lLmg+CiAjaW5jbHVkZSA8YXNtL3NldHVwLmg+CisjaW5jbHVkZSA8YXNtL3NtcC5o
PgogCiAjaW5jbHVkZSA8bWFjaF9hcGljLmg+CiAjaWZkZWYgQ09ORklHX1g4Nl8zMgotLSAKMS41
LjYuNgoK
------=_Part_265887_17688763.1231681592975--
