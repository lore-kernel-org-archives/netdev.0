From: "Gary N Spiess" <Gary.Spiess@intermec.com>
Subject: [PATCH] natsemi update 1/4 Use assigned MAC address
Date: Fri, 04 Jun 2004 14:51:59 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406041451590078.0BC23855@136.179.85.112>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=====_108637871916827=_"
Cc: manfred@colorfullife.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=====_108637871916827=_
Content-Type: multipart/alternative; boundary="=====_10863787199961=_"

--=====_10863787199961=_
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable

Jeff,
This is the first of a series of patches needed to support our product=
 using the DP83815.
This patch accepts the MAC address as a parameter because our=
 implementation does not have an EEPROM.  I tried to upgrade to the new=
 module_param_array() macro, but couldn't find a tutorial on the new param=
 scheme.  To get things working for our development, I use a __setup()=
 wrapper to get "ethaddr=3D" from the linux command line.
Gary
 oooooooooooooooooooooooooooooooooooooooooooooooooo
 Gary Spiess (Gary.Spiess@Intermec.com)
 MobileLan Wireless Products Group, Intermec Technology Corp
 voice: 319 369-3580  fax: 319 369-3804


--=====_10863787199961=_
Content-Type: text/html; charset="us-ascii"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=Content-Type content="text/html; charset=iso-8859-1">
<META content="MSHTML 6.00.2800.1400" name=GENERATOR></HEAD>
<BODY style="FONT-FAMILY: Courier New" text=#000000 bgColor=#ffffff><FONT 
size=4>
<P>Jeff,</P>
<P>This is the&nbsp;first of a series of patches needed to support our product 
using the DP83815.</P>
<P>This patch accepts the MAC address as a parameter because our implementation 
does not have an EEPROM.&nbsp; I tried to upgrade to&nbsp;the new 
module_param_array() macro, but couldn't find a tutorial on the new param 
scheme.&nbsp; To get things working for our development, I use a __setup() 
wrapper to get "ethaddr=" from the linux command line.</P>
<P>Gary</P></FONT></BODY></HTML>

<PRE>
 oooooooooooooooooooooooooooooooooooooooooooooooooo
 Gary Spiess (Gary.Spiess@Intermec.com)
 MobileLan Wireless Products Group, Intermec Technology Corp
 voice: 319 369-3580  fax: 319 369-3804</PRE>


--=====_10863787199961=_--

--=====_108637871916827=_
Content-Type: application/octet-stream; name="natsemi-2.6.6-1.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="natsemi-2.6.6-1.patch"

LS0tIGxpbnV4LTIuNi42L2RyaXZlcnMvbmV0L25hdHNlbWkuYwkyMDA0LTA2
LTAyIDEzOjMxOjM3LjAwMDAwMDAwMCAtMDUwMAorKysgbGludXgvZHJpdmVy
cy9uZXQvbmF0c2VtaS5jCTIwMDQtMDYtMDIgMTY6NTY6MzguMDAwMDAwMDAw
IC0wNTAwCkBAIC0xNDcsNiArMTQ3LDcgQEAKIAogI2luY2x1ZGUgPGxpbnV4
L2NvbmZpZy5oPgogI2luY2x1ZGUgPGxpbnV4L21vZHVsZS5oPgorI2luY2x1
ZGUgPGxpbnV4L21vZHVsZXBhcmFtLmg+CiAjaW5jbHVkZSA8bGludXgva2Vy
bmVsLmg+CiAjaW5jbHVkZSA8bGludXgvc3RyaW5nLmg+CiAjaW5jbHVkZSA8
bGludXgvdGltZXIuaD4KQEAgLTIwOSw2ICsyMTAsOCBAQAogI2RlZmluZSBN
QVhfVU5JVFMgOAkJLyogTW9yZSBhcmUgc3VwcG9ydGVkLCBsaW1pdCBvbmx5
IG9uIG9wdGlvbnMgKi8KIHN0YXRpYyBpbnQgb3B0aW9uc1tNQVhfVU5JVFNd
Owogc3RhdGljIGludCBmdWxsX2R1cGxleFtNQVhfVU5JVFNdOworc3RhdGlj
IGNoYXIgKmV0aGFkZHJbTUFYX1VOSVRTXSA9IHtOVUxMLCB9Oworc3RhdGlj
IGludCBldGhhZGRyX251bSA9IDA7CiAKIC8qIE9wZXJhdGlvbmFsIHBhcmFt
ZXRlcnMgdGhhdCBhcmUgc2V0IGF0IGNvbXBpbGUgdGltZS4gKi8KIApAQCAt
MjU2LDYgKzI1OSw3IEBACiBNT0RVTEVfUEFSTShyeF9jb3B5YnJlYWssICJp
Iik7CiBNT0RVTEVfUEFSTShvcHRpb25zLCAiMS0iIF9fTU9EVUxFX1NUUklO
RyhNQVhfVU5JVFMpICJpIik7CiBNT0RVTEVfUEFSTShmdWxsX2R1cGxleCwg
IjEtIiBfX01PRFVMRV9TVFJJTkcoTUFYX1VOSVRTKSAiaSIpOworbW9kdWxl
X3BhcmFtX2FycmF5KGV0aGFkZHIsIGNoYXJwLCBldGhhZGRyX251bSwgU19J
UlVHTyk7CiBNT0RVTEVfUEFSTV9ERVNDKG1heF9pbnRlcnJ1cHRfd29yaywg
CiAJIkRQODM4MXggbWF4aW11bSBldmVudHMgaGFuZGxlZCBwZXIgaW50ZXJy
dXB0Iik7CiBNT0RVTEVfUEFSTV9ERVNDKG10dSwgIkRQODM4MXggTVRVIChh
bGwgYm9hcmRzKSIpOwpAQCAtMjY1LDYgKzI2OSw3IEBACiBNT0RVTEVfUEFS
TV9ERVNDKG9wdGlvbnMsIAogCSJEUDgzODF4OiBCaXRzIDAtMzogbWVkaWEg
dHlwZSwgYml0IDE3OiBmdWxsIGR1cGxleCIpOwogTU9EVUxFX1BBUk1fREVT
QyhmdWxsX2R1cGxleCwgIkRQODM4MXggZnVsbCBkdXBsZXggc2V0dGluZyhz
KSAoMSkiKTsKK01PRFVMRV9QQVJNX0RFU0MoZXRoYWRkciwgIkRQODM4MXgg
TUFDIGFkZHIocykgeHg6eHg6eHg6eHg6eHg6eHgiKTsKIAogLyoKIAkJCQlU
aGVvcnkgb2YgT3BlcmF0aW9uCkBAIC03NzYsMTMgKzc4MSwyMiBAQAogCQln
b3RvIGVycl9pb3JlbWFwOwogCX0KIAotCS8qIFdvcmsgYXJvdW5kIHRoZSBk
cm9wcGVkIHNlcmlhbCBiaXQuICovCi0JcHJldl9lZWRhdGEgPSBlZXByb21f
cmVhZChpb2FkZHIsIDYpOwotCWZvciAoaSA9IDA7IGkgPCAzOyBpKyspIHsK
LQkJaW50IGVlZGF0YSA9IGVlcHJvbV9yZWFkKGlvYWRkciwgaSArIDcpOwot
CQlkZXYtPmRldl9hZGRyW2kqMl0gPSAoZWVkYXRhIDw8IDEpICsgKHByZXZf
ZWVkYXRhID4+IDE1KTsKLQkJZGV2LT5kZXZfYWRkcltpKjIrMV0gPSBlZWRh
dGEgPj4gNzsKLQkJcHJldl9lZWRhdGEgPSBlZWRhdGE7CisJaWYgKGZpbmRf
Y250IDwgZXRoYWRkcl9udW0pCisJeworCQlpbnQgaSwgYVs2XTsKKwkJc3Nj
YW5mKGV0aGFkZHJbZmluZF9jbnRdLCAiJTJ4OiUyeDolMng6JTJ4OiUyeDol
MngiLAorCQkJJmFbMF0sICZhWzFdLCAmYVsyXSwgJmFbM10sICZhWzRdLCAm
YVs1XSk7CisJCWZvciAoaSA9IDY7IGktLTsgKQorCQkJZGV2LT5kZXZfYWRk
cltpXSA9ICh1bnNpZ25lZCBjaGFyKWFbaV07CisJfSBlbHNlIHsKKwkJLyog
V29yayBhcm91bmQgdGhlIGRyb3BwZWQgc2VyaWFsIGJpdC4gKi8KKwkJcHJl
dl9lZWRhdGEgPSBlZXByb21fcmVhZChpb2FkZHIsIDYpOworCQlmb3IgKGkg
PSAwOyBpIDwgMzsgaSsrKSB7CisJCQlpbnQgZWVkYXRhID0gZWVwcm9tX3Jl
YWQoaW9hZGRyLCBpICsgNyk7CisJCQlkZXYtPmRldl9hZGRyW2kqMl0gPSAo
ZWVkYXRhIDw8IDEpICsgKHByZXZfZWVkYXRhID4+IDE1KTsKKwkJCWRldi0+
ZGV2X2FkZHJbaSoyKzFdID0gZWVkYXRhID4+IDc7CisJCQlwcmV2X2VlZGF0
YSA9IGVlZGF0YTsKKwkJfQogCX0KIAogCWRldi0+YmFzZV9hZGRyID0gaW9h
ZGRyOwpAQCAtMjY5Niw2ICsyNzEyLDI4IEBACiAJcGNpX3VucmVnaXN0ZXJf
ZHJpdmVyICgmbmF0c2VtaV9kcml2ZXIpOwogfQogCisvKiBwZXJtaXQgZXRo
YWRkciB0byBiZSBzcGVjaWZpZWQgaW4gdGhlIGxpbnV4IGNvbW1hbmQgbGlu
ZSBhcworICogYm9vdGFyZ3M9ImV0aGFkZHI9eHg6eHg6eHg6eHg6eHg6eHgi
LgorICovCitzdGF0aWMgaW50IF9faW5pdCBnZXRfbWFjX2FkZHIoY2hhciAq
c3RyKQoreworCS8qIGNhbid0IGRlYWwgd2l0aCBtdWx0aXBsZSBkZWZpbml0
aW9ucyAqLworCWlmICghZXRoYWRkcl9udW0pCisJeworCQlzdGF0aWMgdW5z
aWduZWQgY2hhciB0ZW1wZXRoYWRkclsxOF07CisKKwkJLyogVW5zYWZlIHRv
IGp1c3Qgc2F2ZSB0aGUgcG9pbnRlcj8gIEknbGwgbWFrZSBhIGNvcHkgKi8K
KwkJc3RybmNweSh0ZW1wZXRoYWRkciwgc3RyLCBzaXplb2YodGVtcGV0aGFk
ZHIpKTsKKwkJdGVtcGV0aGFkZHJbc2l6ZW9mKHRlbXBldGhhZGRyKS0xXSA9
IDA7CisKKwkJLyogRG8gd2hhdCBJIHRoaW5rIG1vZHVsZV9wYXJhbV9hcnJh
eSgpIHNob3VsZCBkbyAqLworCQlldGhhZGRyW2V0aGFkZHJfbnVtKytdID0g
dGVtcGV0aGFkZHI7CisJfQorCXJldHVybiAwOworfQorCitfX3NldHVwKCJl
dGhhZGRyPSIsIGdldF9tYWNfYWRkcik7CisKIG1vZHVsZV9pbml0KG5hdHNl
bWlfaW5pdF9tb2QpOwogbW9kdWxlX2V4aXQobmF0c2VtaV9leGl0X21vZCk7
CiAK

--=====_108637871916827=_--
