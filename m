From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 11:08:24 -0800
Message-ID: <CA+55aFzNJbM=ohXninJ06518e3a6E8vySg8GT6dx+Qovk1QW0Q@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
 <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
 <4F0E3B7E.8040005@lwfinger.net> <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
 <4F0E5E57.9060204@lwfinger.net> <CA+55aFw0XArx0jpNh4dWYFmvJbb+GJYAWRUN2Ec14oREiATo7g@mail.gmail.com>
 <CA+55aFxDOr_TT+kxp1SuwNFfm7KLTaWSLQwk1Fx8fWe7tdstcg@mail.gmail.com>
 <CA+55aFzkCXnHfF_TO5M+gaN4RMvj_WNuW_QeBezuYBdWnwPDpg@mail.gmail.com> <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf30363877321be204b6597a8d
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Arend van Spriel <arend@broadcom.com>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:40428 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560Ab2ALTIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 14:08:45 -0500
Received: by yhjj63 with SMTP id j63so1124043yhj.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 11:08:45 -0800 (PST)
In-Reply-To: <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--20cf30363877321be204b6597a8d
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Jan 12, 2012 at 11:00 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I'll send out a patch that seems to get things to a working state for
> me. At least I have wireless connectivity again, I don't know if there
> are some other problems remaining.

Ok, this is the patch that gets me going, and this is sent from the Macbook Air.

NOTE! The BCMA confusion about the sprom still exists, but doesn't
seem to matter:

 bcma: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800, rev 0x22, class 0x0)
 bcma: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812, rev 0x17, class 0x0)
 bcma: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev 0x0F, class 0x0)
 bcma: Found rev 6 PMU (capabilities 0x108C2606)
 bcma: Unsupported SPROM revision: 255
 bcma: No SPROM available
 bcma: Bus registered
  ..
 brcmsmac bcma0:0: mfg 4bf core 812 rev 23 class 0 irq 17
 brcmsmac: Found chip type AI (0x1381a8d8)
 brcmsmac: Applying 43224B0+ WARs
 bcma: Switched to core: 0x812
 ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
 brcms_module_init: register returned 0

so this does seem to work, but there are clearly some issues still..

                 Linus

--20cf30363877321be204b6597a8d
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gxc5jas80

IGRyaXZlcnMvbmV0L3dpcmVsZXNzL2JyY204MDIxMS9NYWtlZmlsZSAgICAgICAgfCAgICAyICst
CiBkcml2ZXJzL25ldC93aXJlbGVzcy9icmNtODAyMTEvYnJjbXNtYWMvc3JvbS5jIHwgICAzMSAr
KysrKysrKysrKysrKystLS0tLS0tLQogMiBmaWxlcyBjaGFuZ2VkLCAyMSBpbnNlcnRpb25zKCsp
LCAxMiBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC93aXJlbGVzcy9icmNt
ODAyMTEvTWFrZWZpbGUgYi9kcml2ZXJzL25ldC93aXJlbGVzcy9icmNtODAyMTEvTWFrZWZpbGUK
aW5kZXggZjQxYzA0N2VjYTgyLi5iYWU1MjE5Y2Q4YmUgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0
L3dpcmVsZXNzL2JyY204MDIxMS9NYWtlZmlsZQorKysgYi9kcml2ZXJzL25ldC93aXJlbGVzcy9i
cmNtODAyMTEvTWFrZWZpbGUKQEAgLTE2LDcgKzE2LDcgQEAKICMgQ09OTkVDVElPTiBXSVRIIFRI
RSBVU0UgT1IgUEVSRk9STUFOQ0UgT0YgVEhJUyBTT0ZUV0FSRS4KIAogIyBjb21tb24gZmxhZ3MK
LXN1YmRpci1jY2ZsYWdzLSQoQ09ORklHX0JSQ01EQkcpCSs9IC1EQkNNREJHCitzdWJkaXItY2Nm
bGFncy0kKENPTkZJR19CUkNNREJHKQkrPSAtREJDTURCRyAtRERFQlVHCiAKIG9iai0kKENPTkZJ
R19CUkNNVVRJTCkJKz0gYnJjbXV0aWwvCiBvYmotJChDT05GSUdfQlJDTUZNQUMpCSs9IGJyY21m
bWFjLwpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvd2lyZWxlc3MvYnJjbTgwMjExL2JyY21zbWFj
L3Nyb20uYyBiL2RyaXZlcnMvbmV0L3dpcmVsZXNzL2JyY204MDIxMS9icmNtc21hYy9zcm9tLmMK
aW5kZXggNjEwOTIxNTY3NTVlLi41NjM3NDM2NDMwMzggMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0
L3dpcmVsZXNzL2JyY204MDIxMS9icmNtc21hYy9zcm9tLmMKKysrIGIvZHJpdmVycy9uZXQvd2ly
ZWxlc3MvYnJjbTgwMjExL2JyY21zbWFjL3Nyb20uYwpAQCAtNzY0LDYgKzc2NCwyMiBAQCBfaW5p
dHZhcnNfc3JvbV9wY2kodTggc3JvbXJldiwgdTE2ICpzcm9tLCBzdHJ1Y3QgbGlzdF9oZWFkICp2
YXJfbGlzdCkKIH0KIAogLyoKKyAqIFRoZSBjcmMgY2hlY2sgaXMgZG9uZSBvbiBhIGxpdHRsZS1l
bmRpYW4gYXJyYXksIHdlIG5lZWQKKyAqIHRvIHN3aXRjaCB0aGUgYnl0ZXMgYXJvdW5kIGJlZm9y
ZSBjaGVja2luZyBjcmMgKGFuZAorICogdGhlbiBzd2l0Y2ggaXQgYmFjaykuCisgKi8KK3N0YXRp
YyBpbnQgZG9fY3JjX2NoZWNrKHUxNiAqYnVmLCB1bnNpZ25lZCBud29yZHMpCit7CisJdTggY3Jj
OworCisJY3B1X3RvX2xlMTZfYnVmKGJ1ZiwgbndvcmRzKTsKKwljcmMgPSBjcmM4KGJyY21zX3Ny
b21fY3JjOF90YWJsZSwgKHZvaWQgKilidWYsIG53b3JkcyA8PCAxLCBDUkM4X0lOSVRfVkFMVUUp
OworCWxlMTZfdG9fY3B1X2J1ZihidWYsIG53b3Jkcyk7CisKKwlyZXR1cm4gY3JjID09IENSQzhf
R09PRF9WQUxVRShicmNtc19zcm9tX2NyYzhfdGFibGUpOworfQorCisvKgogICogUmVhZCBpbiBh
bmQgdmFsaWRhdGUgc3Byb20uCiAgKiBSZXR1cm4gMCBvbiBzdWNjZXNzLCBub256ZXJvIG9uIGVy
cm9yLgogICovCkBAIC03NzIsOCArNzg4LDYgQEAgc3Byb21fcmVhZF9wY2koc3RydWN0IHNpX3B1
YiAqc2loLCB1MTYgKmJ1ZiwgdWludCBud29yZHMsIGJvb2wgY2hlY2tfY3JjKQogewogCWludCBl
cnIgPSAwOwogCXVpbnQgaTsKLQl1OCAqYmJ1ZiA9ICh1OCAqKWJ1ZjsgLyogYnl0ZSBidWZmZXIg
Ki8KLQl1aW50IG5ieXRlcyA9IG53b3JkcyA8PCAxOwogCXN0cnVjdCBiY21hX2RldmljZSAqY29y
ZTsKIAl1aW50IHNwcm9tX29mZnNldDsKIApAQCAtNzg2LDkgKzgwMCw5IEBAIHNwcm9tX3JlYWRf
cGNpKHN0cnVjdCBzaV9wdWIgKnNpaCwgdTE2ICpidWYsIHVpbnQgbndvcmRzLCBib29sIGNoZWNr
X2NyYykKIAkJc3Byb21fb2Zmc2V0ID0gQ0hJUENSRUdPRkZTKHNyb21vdHApOwogCX0KIAotCS8q
IHJlYWQgdGhlIHNwcm9tIGluIGJ5dGVzICovCi0JZm9yIChpID0gMDsgaSA8IG5ieXRlczsgaSsr
KQotCQliYnVmW2ldID0gYmNtYV9yZWFkOChjb3JlLCBzcHJvbV9vZmZzZXQraSk7CisJLyogcmVh
ZCB0aGUgc3Byb20gKi8KKwlmb3IgKGkgPSAwOyBpIDwgbndvcmRzOyBpKyspCisJCWJ1ZltpXSA9
IGJjbWFfcmVhZDE2KGNvcmUsIHNwcm9tX29mZnNldCtpKjIpOwogCiAJaWYgKGJ1ZlswXSA9PSAw
eGZmZmYpCiAJCS8qCkBAIC03OTgsMTMgKzgxMiw4IEBAIHNwcm9tX3JlYWRfcGNpKHN0cnVjdCBz
aV9wdWIgKnNpaCwgdTE2ICpidWYsIHVpbnQgbndvcmRzLCBib29sIGNoZWNrX2NyYykKIAkJICov
CiAJCXJldHVybiAtRU5PREFUQTsKIAotCWlmIChjaGVja19jcmMgJiYKLQkgICAgY3JjOChicmNt
c19zcm9tX2NyYzhfdGFibGUsIGJidWYsIG5ieXRlcywgQ1JDOF9JTklUX1ZBTFVFKSAhPQotCQkg
Q1JDOF9HT09EX1ZBTFVFKGJyY21zX3Nyb21fY3JjOF90YWJsZSkpCisJaWYgKGNoZWNrX2NyYyAm
JiAhZG9fY3JjX2NoZWNrKGJ1ZiwgbndvcmRzKSkKIAkJZXJyID0gLUVJTzsKLQllbHNlCi0JCS8q
IG5vdyBjb3JyZWN0IHRoZSBlbmRpYW5uZXNzIG9mIHRoZSBieXRlIGFycmF5ICovCi0JCWxlMTZf
dG9fY3B1X2J1ZihidWYsIG53b3Jkcyk7CiAKIAlyZXR1cm4gZXJyOwogfQo=
--20cf30363877321be204b6597a8d--
