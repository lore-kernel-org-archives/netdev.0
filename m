From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Sun, 19 Dec 2010 23:26:23 +0100
Message-ID: <4D0E868F.90005@gmail.com>
References: <4D0DEDF9.7020102@itcare.pl> <1292773433.18869.153.camel@edumazet-laptop> <4D0E2E52.3090802@itcare.pl> <AANLkTimMY3D_HssWb=Sw=b3tsxEKACk2QUzFzi-HaC-J@mail.gmail.com> <4D0E6C6D.10806@itcare.pl> <4D0E8416.2030100@gmail.com> <4D0E857E.5060302@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080809020503070306020403"
Cc: Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37844 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932078Ab0LSW02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Dec 2010 17:26:28 -0500
Received: by wyb28 with SMTP id 28so2332220wyb.19
        for <netdev@vger.kernel.org>; Sun, 19 Dec 2010 14:26:26 -0800 (PST)
In-Reply-To: <4D0E857E.5060302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080809020503070306020403
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Jarek Poplawski wrote:
> Jarek Poplawski wrote:
>> Paweł Staszewski wrote:
> 
>>> for sch_generic.h was ok.
>>
>> Should be enough to try after reverting this sch_generic.h change only.
> 
> Hmm... Sorry, I meant the change inside skb_act_clone(). I'll send a patch.

Here it is.
  
Jarek P.


--------------080809020503070306020403
Content-Type: text/plain;
 name="sch_generic.h.act_clone.1.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="sch_generic.h.act_clone.1.diff"

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L3NjaF9nZW5lcmljLmggYi9pbmNsdWRlL25ldC9z
Y2hfZ2VuZXJpYy5oCmluZGV4IGVhMWY4YTguLjg3NjNjY2MgMTAwNjQ0Ci0tLSBhL2luY2x1
ZGUvbmV0L3NjaF9nZW5lcmljLmgKKysrIGIvaW5jbHVkZS9uZXQvc2NoX2dlbmVyaWMuaApA
QCAtNjA4LDEzICs2MDgsNyBAQCBzdGF0aWMgaW5saW5lIHUzMiBxZGlzY19sMnQoc3RydWN0
IHFkaXNjX3JhdGVfdGFibGUqIHJ0YWIsIHVuc2lnbmVkIGludCBwa3RsZW4pCiBzdGF0aWMg
aW5saW5lIHN0cnVjdCBza19idWZmICpza2JfYWN0X2Nsb25lKHN0cnVjdCBza19idWZmICpz
a2IsIGdmcF90IGdmcF9tYXNrLAogCQkJCQkgICAgaW50IGFjdGlvbikKIHsKLQlzdHJ1Y3Qg
c2tfYnVmZiAqbjsKLQotCWlmICgoYWN0aW9uID09IFRDX0FDVF9TVE9MRU4gfHwgYWN0aW9u
ID09IFRDX0FDVF9RVUVVRUQpICYmCi0JICAgICFza2Jfc2hhcmVkKHNrYikpCi0JCW4gPSBz
a2JfZ2V0KHNrYik7Ci0JZWxzZQotCQluID0gc2tiX2Nsb25lKHNrYiwgZ2ZwX21hc2spOwor
CXN0cnVjdCBza19idWZmICpuID0gc2tiX2Nsb25lKHNrYiwgZ2ZwX21hc2spOwogCiAJaWYg
KG4pIHsKIAkJbi0+dGNfdmVyZCA9IFNFVF9UQ19WRVJEKG4tPnRjX3ZlcmQsIDApOwo=
--------------080809020503070306020403--
