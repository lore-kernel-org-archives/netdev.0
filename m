From: Fabio Ludovici <fabio.ludovici@yahoo.it>
Subject: Re: [PATCH] netem/iproute2 solving correlated loss issues [0/5]
Date: Fri, 18 Dec 2009 12:22:15 +0100
Message-ID: <4B2B65E7.1090508@yahoo.it>
References: <4B2B5BD1.7040602@uniroma2.it>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080304040800020000080503"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:55881 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbZLRLWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 06:22:20 -0500
Received: by fxm21 with SMTP id 21so2696997fxm.21
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 03:22:18 -0800 (PST)
In-Reply-To: <4B2B5BD1.7040602@uniroma2.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080304040800020000080503
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

patch 1/5 : linux-2.6.32/include/linux/pkt_sched.h

--------------080304040800020000080503
Content-Type: text/plain;
 name="netem_patch_1_of_5"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="netem_patch_1_of_5"

ZGlmZiAtdU5yIGxpbnV4LTIuNi4zMi9pbmNsdWRlL2xpbnV4L3BrdF9zY2hlZC5oIGxpbnV4
LTIuNi4zMi1uZXRlbS9pbmNsdWRlL2xpbnV4L3BrdF9zY2hlZC5oDQotLS0gbGludXgtMi42
LjMyL2luY2x1ZGUvbGludXgvcGt0X3NjaGVkLmgJMjAwOS0xMi0wMyAwNDo1MToyMS4wMDAw
MDAwMDAgKzAxMDANCisrKyBsaW51eC0yLjYuMzItbmV0ZW0vaW5jbHVkZS9saW51eC9wa3Rf
c2NoZWQuaAkyMDA5LTEyLTExIDEyOjU5OjEyLjYzNDE4Nzg3NyArMDEwMA0KQEAgLTQ3OSw2
ICs0NzksMjEgQEANCiAJX191MzIJZ2FwOwkJLyogcmUtb3JkZXJpbmcgZ2FwICgwIGZvciBu
b25lKSAqLw0KIAlfX3UzMiAgIGR1cGxpY2F0ZTsJLyogcmFuZG9tIHBhY2tldCBkdXAgICgw
PW5vbmUgfjA9MTAwJSkgKi8NCiAJX191MzIJaml0dGVyOwkJLyogcmFuZG9tIGppdHRlciBp
biBsYXRlbmN5ICh1cykgKi8NCisJX191MzIJcDEzOwkJLyogR0kgbG9zcyBtb2RlbC1zdGF0
ZSAxIHRvIDMgdHJhbnNpdGlvbiBwcm9iYWJpbGl0eSAqLw0KKwlfX3UzMglwMzE7CQkvKiBH
SSBsb3NzIG1vZGVsLXN0YXRlIDMgdG8gMSB0cmFuc2l0aW9uIHByb2JhYmlsaXR5ICovDQor
CV9fdTMyCXAzMjsJCS8qIEdJIGxvc3MgbW9kZWwtc3RhdGUgMyB0byAyIHRyYW5zaXRpb24g
cHJvYmFiaWxpdHkgKi8NCisJX191MzIJcDIzOwkJLyogR0kgbG9zcyBtb2RlbC1zdGF0ZSAy
IHRvIDMgdHJhbnNpdGlvbiBwcm9iYWJpbGl0eSAqLw0KKwlfX3UzMiAgIHAxNDsJCS8qIEdJ
IGxvc3MgbW9kZWwtc3RhdGUgMSB0byA0IHRyYW5zaXRpb24gcHJvYmFiaWxpdHkgKi8NCisJ
X191MzIJZ2lsYl9wOwkJLyogR2lsYmVydC1FbGxpb3QgbW9kZWwtc3RhdGUgZ29vZC1iYWQg
dHJhbnNpdGlvbiBwcm9iYWJpbGl0eSAqLw0KKwlfX3UzMglnaWxiX3I7CQkvKiBHaWxiZXJ0
LUVsbGlvdCBtb2RlbC1zdGF0ZSBiYWQtZ29vZCB0cmFuc2l0aW9uIHByb2JhYmlsaXR5ICov
DQorCV9fdTMyCWdpbGJfaDsJCS8qIEdpbGJlcnQtRWxsaW90LWxvc3MgbW9kZWwgbG9zcyBw
cm9iYWJpbGl0eSBpbiBiYWQgc3RhdGUgKi8NCisJX191MzIJZ2lsYl9rOwkJLyogR2lsYmVy
dC1FbGxpb3QtbG9zcyBtb2RlbCBsb3NzIHByb2JhYmlsaXR5IGluIGdvb2Qgc3RhdGUgKi8N
CisJX191MzIgICBhbGdvcml0aG07CS8qIGxvc3MgbW9kZWwgYWxnb3JpdGhtIHNlbGVjdGlv
biAqLw0KKwlfX3UzMiAJbG9nZ2luZzsgIAkvKiBsb3NzIGxvZ2dpbmcgbW9kZSBzZWxlY3Rv
ciAqLw0KKwlfX3UzMiAgIHF1ZXJ5OwkJLyogbG9zcyBxdWVyeSBtb2RlIHNlbGVjdG9yICov
DQorCV9fdTE2ICAgcGF0dGVybl9sZW5ndGg7IC8qIGRldGVybWluaXN0aWMgbG9zcyBwYXR0
ZXJuIGxlbmd0aCAqLw0KKwlfX3UzMiAgIHBhdHRlcm5fcmVwZXRpdGlvbnM7IC8qIGRldGVy
bWluaXN0YyBsb3NzIHBhdHRlcm4gcmVwZXRpdGlvbnMgKi8NCisJX191MTYgICAqdXNlcl9w
YXR0ZXJuOyAvKiBkZXRlcm1pbmlzdCBsb3NzIHBhdHRlcm4gZWxlbWVudHMgKi8NCiB9Ow0K
IA0KIHN0cnVjdCB0Y19uZXRlbV9jb3Jy
--------------080304040800020000080503--
