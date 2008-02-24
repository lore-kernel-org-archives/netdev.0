From: "Julio Kriger" <juliokriger@gmail.com>
Subject: Fixed delay patch for netem
Date: Sun, 24 Feb 2008 12:11:16 -0200
Message-ID: <682bc30a0802240611r5670fc9etba66cf86a9a78113@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_2528_25123494.1203862276919"
To: netdev@vger.kernel.org, netdev@oss.sgi.com, netem@osdl.org,
	netem@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:33156 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262AbYBXOLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 09:11:19 -0500
Received: by ug-out-1314.google.com with SMTP id z38so420806ugc.16
        for <netdev@vger.kernel.org>; Sun, 24 Feb 2008 06:11:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_2528_25123494.1203862276919
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi!
I have created this patch to add a fixed delay on packet filtered by
netem. Soon I will send the patch to iproute2.
This patch comes from a need I have to delay all packets 50ms, beside
the actual delay setting, like 30ms +- 15 ms. This strike, IMMHO, a
missing point on gap reordering. If I set "gap 5 delay 10ms" every 5th
(10th, 15th, ...) packet to go to be sent immediately and every other
packet to be delayed by 10ms. This  is ok, but I also need a "fixed"
delay of 50ms to be applied to all packets. Since netem can't be
nested with himself (so I can do a fixed delay), I needed this new
feature on netem.
This patch was create with linux kernel version 2.6.24.2.
I hope you like it, and it would be great if it goes shiped with the
next version of the kernel :-))
Regards,
Julio Kriger

-- 
--
>From the moment I picked your book up until I laid it down, I was
convulsed with laughter. Someday I intend reading it.
Groucho Marx
----------------------------
Julio Kriger
mailto:juliokriger@gmail.com

------=_Part_2528_25123494.1203862276919
Content-Type: text/plain; name=fixed_delay_patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fd1nzmla0
Content-Disposition: attachment; filename=fixed_delay_patch

ZGlmZiAtTmF1ciBsaW51eC0yLjYuMjQuMi1vbGQvaW5jbHVkZS9saW51eC9wa3Rfc2NoZWQuaCBs
aW51eC0yLjYuMjQuMi1uZXcvaW5jbHVkZS9saW51eC9wa3Rfc2NoZWQuaAotLS0gbGludXgtMi42
LjI0LjItb2xkL2luY2x1ZGUvbGludXgvcGt0X3NjaGVkLmgJMjAwOC0wMi0xMSAwMzo1MToxMS4w
MDAwMDAwMDAgLTAyMDAKKysrIGxpbnV4LTIuNi4yNC4yLW5ldy9pbmNsdWRlL2xpbnV4L3BrdF9z
Y2hlZC5oCTIwMDgtMDItMjQgMTE6NDg6MTMuMDAwMDAwMDAwIC0wMjAwCkBAIC00NTIsNiArNDUy
LDcgQEAKIAlfX3UzMglnYXA7CQkvKiByZS1vcmRlcmluZyBnYXAgKDAgZm9yIG5vbmUpICovCiAJ
X191MzIgICBkdXBsaWNhdGU7CS8qIHJhbmRvbSBwYWNrZXQgZHVwICAoMD1ub25lIH4wPTEwMCUp
ICovCiAJX191MzIJaml0dGVyOwkJLyogcmFuZG9tIGppdHRlciBpbiBsYXRlbmN5ICh1cykgKi8K
KwlfX3UzMglmaXhlZF9sYXRlbmN5OwkJLyogZml4ZWQgbGF0ZW5jeSBmb3JtIG5ldGVtICovCQog
fTsKIAogc3RydWN0IHRjX25ldGVtX2NvcnIKZGlmZiAtTmF1ciBsaW51eC0yLjYuMjQuMi1vbGQv
bmV0L3NjaGVkL3NjaF9uZXRlbS5jIGxpbnV4LTIuNi4yNC4yLW5ldy9uZXQvc2NoZWQvc2NoX25l
dGVtLmMKLS0tIGxpbnV4LTIuNi4yNC4yLW9sZC9uZXQvc2NoZWQvc2NoX25ldGVtLmMJMjAwOC0w
Mi0xMSAwMzo1MToxMS4wMDAwMDAwMDAgLTAyMDAKKysrIGxpbnV4LTIuNi4yNC4yLW5ldy9uZXQv
c2NoZWQvc2NoX25ldGVtLmMJMjAwOC0wMi0yNCAxMTo0Nzo0MC4wMDAwMDAwMDAgLTAyMDAKQEAg
LTIzLDcgKzIzLDcgQEAKICNpbmNsdWRlIDxuZXQvbmV0bGluay5oPgogI2luY2x1ZGUgPG5ldC9w
a3Rfc2NoZWQuaD4KIAotI2RlZmluZSBWRVJTSU9OICIxLjIiCisjZGVmaW5lIFZFUlNJT04gIjEu
Mi4xIgogCiAvKglOZXR3b3JrIEVtdWxhdGlvbiBRdWV1aW5nIGFsZ29yaXRobS4KIAk9PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KQEAgLTY1LDYgKzY1LDcgQEAKIAl1MzIgZHVw
bGljYXRlOwogCXUzMiByZW9yZGVyOwogCXUzMiBjb3JydXB0OworCXUzMiBmaXhlZF9sYXRlbmN5
OyAvKiBoYW5kbGUgZml4ZWQgZGVsYXkgKi8KIAogCXN0cnVjdCBjcm5kc3RhdGUgewogCQl1MzIg
bGFzdDsKQEAgLTIxNSw2ICsyMTYsMTMgQEAKIAkJZGVsYXkgPSB0YWJsZWRpc3QocS0+bGF0ZW5j
eSwgcS0+aml0dGVyLAogCQkJCSAgJnEtPmRlbGF5X2NvciwgcS0+ZGVsYXlfZGlzdCk7CiAKKwkJ
LyoKKwkJICogQWRkIGZpeGVkIGRlbGF5CisJCSAqLworCQlpZihxLT5maXhlZF9sYXRlbmN5ID4g
MCkgeworCQkJZGVsYXkgKz0gdGFibGVkaXN0KHEtPmZpeGVkX2xhdGVuY3ksIDAsICZxLT5kZWxh
eV9jb3IsIHEtPmRlbGF5X2Rpc3QpOworCQl9CisKIAkJbm93ID0gcHNjaGVkX2dldF90aW1lKCk7
CiAJCWNiLT50aW1lX3RvX3NlbmQgPSBub3cgKyBkZWxheTsKIAkJKytxLT5jb3VudGVyOwpAQCAt
MjI1LDYgKzIzMywxOCBAQAogCQkgKiBvZiB0aGUgcXVldWUuCiAJCSAqLwogCQljYi0+dGltZV90
b19zZW5kID0gcHNjaGVkX2dldF90aW1lKCk7CisKKwkJLyoKKwkJICogQWRkIGZpeGVkIGRlbGF5
CisJCSAqLworCQlpZihxLT5maXhlZF9sYXRlbmN5ID4gMCkgeworCQkJcHNjaGVkX3RpbWVfdCBu
b3c7CisJCQlwc2NoZWRfdGRpZmZfdCBmaXhlZF9kZWxheTsKKwkJCWZpeGVkX2RlbGF5ID0gdGFi
bGVkaXN0KHEtPmZpeGVkX2xhdGVuY3ksIDAsICZxLT5kZWxheV9jb3IsIHEtPmRlbGF5X2Rpc3Qp
OworCQkJbm93ID0gcHNjaGVkX2dldF90aW1lKCk7CisJCQljYi0+dGltZV90b19zZW5kID0gbm93
ICsgZml4ZWRfZGVsYXk7CisJCX0JCisJCQogCQlxLT5jb3VudGVyID0gMDsKIAkJcmV0ID0gcS0+
cWRpc2MtPm9wcy0+cmVxdWV1ZShza2IsIHEtPnFkaXNjKTsKIAl9CkBAIC00MjcsNiArNDQ3LDcg
QEAKIAlxLT5jb3VudGVyID0gMDsKIAlxLT5sb3NzID0gcW9wdC0+bG9zczsKIAlxLT5kdXBsaWNh
dGUgPSBxb3B0LT5kdXBsaWNhdGU7CisJcS0+Zml4ZWRfbGF0ZW5jeSA9IHFvcHQtPmZpeGVkX2xh
dGVuY3k7CiAKIAkvKiBmb3IgY29tcGF0aWJpbGl0eSB3aXRoIGVhcmxpZXIgdmVyc2lvbnMuCiAJ
ICogaWYgZ2FwIGlzIHNldCwgbmVlZCB0byBhc3N1bWUgMTAwJSBwcm9iYWJpbGl0eQpAQCAtNjA3
LDYgKzYyOCw3IEBACiAJcW9wdC5sb3NzID0gcS0+bG9zczsKIAlxb3B0LmdhcCA9IHEtPmdhcDsK
IAlxb3B0LmR1cGxpY2F0ZSA9IHEtPmR1cGxpY2F0ZTsKKwlxb3B0LmZpeGVkX2xhdGVuY3kgPSBx
LT5maXhlZF9sYXRlbmN5OwogCVJUQV9QVVQoc2tiLCBUQ0FfT1BUSU9OUywgc2l6ZW9mKHFvcHQp
LCAmcW9wdCk7CiAKIAljb3IuZGVsYXlfY29yciA9IHEtPmRlbGF5X2Nvci5yaG87Cg==
------=_Part_2528_25123494.1203862276919--
