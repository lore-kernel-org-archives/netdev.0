From: Sundar Nagarajan <sun.nagarajan@gmail.com>
Subject: Fwd: Request to add bluetooth module identifier to net/rfkill/rfkill-gpio.c
Date: Sat, 8 Jul 2017 01:54:33 -0700
Message-ID: <CALnajPCeYP6W4iECCsDegwTmq7UsPcH04C=K0h-zZQD6pf6rZw@mail.gmail.com>
References: <CALnajPDkZi5tOTcghFCRHg8EiLgXXy1nWo+b7R4DxX8iEd1g0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="001a1142b49caea9ea0553ca7fc2"
To: Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:36162 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752636AbdGHIyf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2017 04:54:35 -0400
In-Reply-To: <CALnajPDkZi5tOTcghFCRHg8EiLgXXy1nWo+b7R4DxX8iEd1g0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a1142b49caea9ea0553ca7fc2
Content-Type: text/plain; charset="UTF-8"

Hi,

I have a Cherry Trail laptop with an Atom X5-Z8300. It has a bluetooth
chip that needs the r8723bs (coexisting RTL 8723BS wifi and
bluetooth).

I am using linux-next (20150817) with the r8723bs staging driver and
the firmware and utility from https://github.com/lwfinger/rtl8723bs_bt
by Larry finger.

With linux-next the bluetooth works SOMETIMES, but on reboot, it does
not work any more (no bluetooth interfaces are detected and hciconfig
shows nothing).

I am a kernel novice, but I saw that another kernel that I had tried
had the following line added in struct acpi_device_id
rfkill_acpi_match:

{ "OBDA8723",RFKILL_TYPE_BLUETOOTH }

With the attached patch applied (one line added), my bluetooth works every time.

Does this belong in rfkill-gpio.c, or should I contact someone else?

--001a1142b49caea9ea0553ca7fc2
Content-Type: text/x-patch; charset="US-ASCII";
	name="0001_linux-next-20170516-rdp_bluetooth.patch"
Content-Disposition: attachment;
	filename="0001_linux-next-20170516-rdp_bluetooth.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j2v10tfv0

ZGlmZiAtLWdpdCBhL25ldC9yZmtpbGwvcmZraWxsLWdwaW8uYyBiL25ldC9yZmtpbGwvcmZraWxs
LWdwaW8uYwppbmRleCA3NmMwMWNiLi40ZTMyZGVmIDEwMDY0NAotLS0gYS9uZXQvcmZraWxsL3Jm
a2lsbC1ncGlvLmMKKysrIGIvbmV0L3Jma2lsbC9yZmtpbGwtZ3Bpby5jCkBAIC0xNjMsNiArMTYz
LDcgQEAgc3RhdGljIGludCByZmtpbGxfZ3Bpb19yZW1vdmUoc3RydWN0IHBsYXRmb3JtX2Rldmlj
ZSAqcGRldikKIHN0YXRpYyBjb25zdCBzdHJ1Y3QgYWNwaV9kZXZpY2VfaWQgcmZraWxsX2FjcGlf
bWF0Y2hbXSA9IHsKIAl7ICJCQ000NzUyIiwgUkZLSUxMX1RZUEVfR1BTIH0sCiAJeyAiTE5WNDc1
MiIsIFJGS0lMTF9UWVBFX0dQUyB9LAorICAgICB7ICJPQkRBODcyMyIsUkZLSUxMX1RZUEVfQkxV
RVRPT1RIIH0sCiAJeyB9LAogfTsKIE1PRFVMRV9ERVZJQ0VfVEFCTEUoYWNwaSwgcmZraWxsX2Fj
cGlfbWF0Y2gpOwo=
--001a1142b49caea9ea0553ca7fc2--
