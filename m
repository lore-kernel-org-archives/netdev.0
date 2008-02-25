From: Louis JANG <louis-6CAt/Z4uMM0@public.gmane.org>
Subject: Re: [Bluez-devel] forcing SCO connection patch
Date: Mon, 25 Feb 2008 20:35:22 +0900
Message-ID: <47C2A7FA.2060902@mizi.com>
References: <47666E1F.2000902@mizi.com>	 <a8e1da0802242330l765b8b1ava62b857baf8a5568@mail.gmail.com>	 <47C28A33.4070102@mizi.com> <a8e1da0802250155u1b7af481va203849f68d9106b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010407000406090200060007"
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bmidgley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a8e1da0802250155u1b7af481va203849f68d9106b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010407000406090200060007
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 8bit

Dave Young ¾´ ±Û:
> On Mon, Feb 25, 2008 at 5:28 PM, Louis JANG <louis-6CAt/Z4uMM0@public.gmane.org> wrote:
>   
>>  > I ever asked marcel about the coding style. please see following thread:
>>  > http://lkml.org/lkml/2008/1/22/91
>>  >
>>  > I think the style problem marcel said is
>>  > 1. using kernel codeing style
>>  > 2. marcel's style
>>  > container_of or get_user_data calls at the top of the variable declaration
>>  > using the empty lines to seperate code blocks
>>  >
>>  > Please rework your patch and resend if you fixed them.
>>  >
>>  > BTW, please use the new bluetooth mailing list for kerne issue.
>>  > linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>  >
>>  > (Thanks for andrew and davem)
>>  >
>>  > Regards
>>  > dave
>>  >
>>  > Regards
>>  > dave
>>  >
>>  >
>>
>>  Hi all,
>>
>>  I adjusted indentation of the patches
>>     
>
> Not enough.
>
> Please first read Documentation/CodingStyle, fix them, and
> then use scripts/checkpatch.pl to check your patch.
>   
I fixed all of errors except 80 characters warning.
Thanks

Louis JANG


--------------010407000406090200060007
Content-Type: text/plain;
 name="patch_hci_event.c3"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="patch_hci_event.c3"

U2lnbmVkLW9mZi1ieTogTG91aXMgSkFORyA8bG91aXNAbWl6aS5jb20+CgotLS0gbGludXgt
Mi42LjIzL25ldC9ibHVldG9vdGgvaGNpX2V2ZW50LmMub3JpZwkyMDA4LTAyLTI1IDE3OjE3
OjExLjAwMDAwMDAwMCArMDkwMAorKysgbGludXgtMi42LjIzL25ldC9ibHVldG9vdGgvaGNp
X2V2ZW50LmMJMjAwOC0wMi0yNSAxNzozMDoyMy4wMDAwMDAwMDAgKzA5MDAKQEAgLTEzMTMs
OCArMTMxMywxNyBAQAogCWhjaV9kZXZfbG9jayhoZGV2KTsKIAogCWNvbm4gPSBoY2lfY29u
bl9oYXNoX2xvb2t1cF9iYShoZGV2LCBldi0+bGlua190eXBlLCAmZXYtPmJkYWRkcik7Ci0J
aWYgKCFjb25uKQotCQlnb3RvIHVubG9jazsKKwlpZiAoIWNvbm4pIHsKKwkJaWYgKGV2LT5s
aW5rX3R5cGUgIT0gQUNMX0xJTkspIHsKKwkJCV9fdTggbGlua190eXBlID0gKGV2LT5saW5r
X3R5cGUgPT0gRVNDT19MSU5LKSA/IFNDT19MSU5LIDogRVNDT19MSU5LOworCisJCQljb25u
ID0gaGNpX2Nvbm5faGFzaF9sb29rdXBfYmEoaGRldiwgbGlua190eXBlLCAmZXYtPmJkYWRk
cik7CisJCQlpZiAoY29ubikKKwkJCQljb25uLT50eXBlID0gZXYtPmxpbmtfdHlwZTsKKwkJ
fQorCQlpZiAoIWNvbm4pCisJCQlnb3RvIHVubG9jazsKKwl9CiAKIAlpZiAoIWV2LT5zdGF0
dXMpIHsKIAkJY29ubi0+aGFuZGxlID0gX19sZTE2X3RvX2NwdShldi0+aGFuZGxlKTsK
--------------010407000406090200060007
Content-Type: text/plain;
 name="bluez-kernel-forcesco.patch3"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="bluez-kernel-forcesco.patch3"

U2lnbmVkLW9mZi1ieTogTG91aXMgSkFORyA8bG91aXNAbWl6aS5jb20+CgpkaWZmIC11TnIg
bGludXgtMi42LjIzL2luY2x1ZGUvbmV0L2JsdWV0b290aC1vcmlnL3Njby5oIGxpbnV4LTIu
Ni4yMy9pbmNsdWRlL25ldC9ibHVldG9vdGgvc2NvLmgKLS0tIGxpbnV4LTIuNi4yMy9pbmNs
dWRlL25ldC9ibHVldG9vdGgtb3JpZy9zY28uaAkyMDA3LTEwLTEwIDA1OjMxOjM4LjAwMDAw
MDAwMCArMDkwMAorKysgbGludXgtMi42LjIzL2luY2x1ZGUvbmV0L2JsdWV0b290aC9zY28u
aAkyMDA4LTAyLTI1IDE4OjA0OjIwLjAwMDAwMDAwMCArMDkwMApAQCAtNTEsNiArNTEsOCBA
QAogCV9fdTggIGRldl9jbGFzc1szXTsKIH07CiAKKyNkZWZpbmUgU0NPX0ZPUkNFU0NPCTB4
MDMKKwogLyogLS0tLSBTQ08gY29ubmVjdGlvbnMgLS0tLSAqLwogc3RydWN0IHNjb19jb25u
IHsKIAlzdHJ1Y3QgaGNpX2Nvbm4JKmhjb247CkBAIC03NCw2ICs3Niw3IEBACiAJc3RydWN0
IGJ0X3NvY2sJYnQ7CiAJX191MzIJCWZsYWdzOwogCXN0cnVjdCBzY29fY29ubgkqY29ubjsK
Kwl1bnNpZ25lZCBpbnQJZm9yY2Vfc2NvIDoxOwogfTsKIAogI2VuZGlmIC8qIF9fU0NPX0gg
Ki8KZGlmZiAtdU5yIGxpbnV4LTIuNi4yMy9uZXQvYmx1ZXRvb3RoLW9yaWcvaGNpX2Nvbm4u
YyBsaW51eC0yLjYuMjMvbmV0L2JsdWV0b290aC9oY2lfY29ubi5jCi0tLSBsaW51eC0yLjYu
MjMvbmV0L2JsdWV0b290aC1vcmlnL2hjaV9jb25uLmMJMjAwOC0wMi0yNSAxNzo1ODoyNy4w
MDAwMDAwMDAgKzA5MDAKKysrIGxpbnV4LTIuNi4yMy9uZXQvYmx1ZXRvb3RoL2hjaV9jb25u
LmMJMjAwOC0wMi0yNSAxODowMjowNC4wMDAwMDAwMDAgKzA5MDAKQEAgLTM1NCw3ICszNTQs
NyBAQAogCiAJaWYgKGFjbC0+c3RhdGUgPT0gQlRfQ09OTkVDVEVEICYmCiAJCQkoc2NvLT5z
dGF0ZSA9PSBCVF9PUEVOIHx8IHNjby0+c3RhdGUgPT0gQlRfQ0xPU0VEKSkgewotCQlpZiAo
bG1wX2VzY29fY2FwYWJsZShoZGV2KSkKKwkJaWYgKHR5cGUgPT0gRVNDT19MSU5LKQogCQkJ
aGNpX3NldHVwX3N5bmMoc2NvLCBhY2wtPmhhbmRsZSk7CiAJCWVsc2UKIAkJCWhjaV9hZGRf
c2NvKHNjbywgYWNsLT5oYW5kbGUpOwpkaWZmIC11TnIgbGludXgtMi42LjIzL25ldC9ibHVl
dG9vdGgtb3JpZy9zY28uYyBsaW51eC0yLjYuMjMvbmV0L2JsdWV0b290aC9zY28uYwotLS0g
bGludXgtMi42LjIzL25ldC9ibHVldG9vdGgtb3JpZy9zY28uYwkyMDA4LTAyLTI1IDE3OjU4
OjI3LjAwMDAwMDAwMCArMDkwMAorKysgbGludXgtMi42LjIzL25ldC9ibHVldG9vdGgvc2Nv
LmMJMjAwOC0wMi0yNSAxODowODo1MS4wMDAwMDAwMDAgKzA5MDAKQEAgLTIwMCw3ICsyMDAs
MTAgQEAKIAogCWVyciA9IC1FTk9NRU07CiAKLQl0eXBlID0gbG1wX2VzY29fY2FwYWJsZSho
ZGV2KSA/IEVTQ09fTElOSyA6IFNDT19MSU5LOworCWlmIChzY29fcGkoc2spLT5mb3JjZV9z
Y28pCisJCXR5cGUgPSBTQ09fTElOSzsKKwllbHNlCisJCXR5cGUgPSBsbXBfZXNjb19jYXBh
YmxlKGhkZXYpID8gRVNDT19MSU5LIDogU0NPX0xJTks7CiAKIAloY29uID0gaGNpX2Nvbm5l
Y3QoaGRldiwgdHlwZSwgZHN0KTsKIAlpZiAoIWhjb24pCkBAIC02NjAsMTIgKzY2MywyMSBA
QAogewogCXN0cnVjdCBzb2NrICpzayA9IHNvY2stPnNrOwogCWludCBlcnIgPSAwOworCWlu
dCBmb3JjZV9zY287CiAKIAlCVF9EQkcoInNrICVwIiwgc2spOwogCiAJbG9ja19zb2NrKHNr
KTsKIAogCXN3aXRjaCAob3B0bmFtZSkgeworCWNhc2UgU0NPX0ZPUkNFU0NPOgorCQlpZiAo
Y29weV9mcm9tX3VzZXIoJmZvcmNlX3Njbywgb3B0dmFsLCBzaXplb2YoaW50KSkpIHsKKwkJ
CWVyciA9IC1FRkFVTFQ7CisJCQlicmVhazsKKwkJfQorCQlzY29fcGkoc2spLT5mb3JjZV9z
Y28gPSAoZm9yY2Vfc2NvICE9IDApOworCQlicmVhazsKKwogCWRlZmF1bHQ6CiAJCWVyciA9
IC1FTk9QUk9UT09QVDsKIAkJYnJlYWs7CkBAIC02ODEsNiArNjkzLDcgQEAKIAlzdHJ1Y3Qg
c2NvX29wdGlvbnMgb3B0czsKIAlzdHJ1Y3Qgc2NvX2Nvbm5pbmZvIGNpbmZvOwogCWludCBs
ZW4sIGVyciA9IDA7CisJaW50IGZvcmNlX3NjbzsKIAogCUJUX0RCRygic2sgJXAiLCBzayk7
CiAKQEAgLTcyMSw2ICs3MzQsMTMgQEAKIAogCQlicmVhazsKIAorCWNhc2UgU0NPX0ZPUkNF
U0NPOgorCQlmb3JjZV9zY28gPSBzY29fcGkoc29jayktPmZvcmNlX3NjbzsKKwkJaWYgKGNv
cHlfdG9fdXNlcihvcHR2YWwsICZmb3JjZV9zY28sIHNpemVvZihpbnQpKSkKKwkJCWVyciA9
IC1FRkFVTFQ7CisKKwkJYnJlYWs7CisKIAlkZWZhdWx0OgogCQllcnIgPSAtRU5PUFJPVE9P
UFQ7CiAJCWJyZWFrOwo=
--------------010407000406090200060007--
-
To unsubscribe from this list: send the line "unsubscribe linux-bluetooth" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
