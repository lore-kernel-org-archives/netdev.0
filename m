From: "Ranjit Manomohan" <ranjitm@google.com>
Subject: Re: [PATCH][NET_SCHED] Make HTB scheduler work with TSO.
Date: Tue, 10 Jul 2007 15:02:16 -0700
Message-ID: <166fe7950707101502w65447adcm3f284df9494440ed@mail.gmail.com>
References: <Pine.LNX.4.63.0706121647280.4120@ranjit.corp.google.com>
	 <20070709.151522.52166816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_145392_31260528.1184104936582"
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:15059 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756926AbXGJWCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 18:02:23 -0400
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id l6AM2Kk1023133
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2007 15:02:20 -0700
Received: from ik-out-1112.google.com (ikab35.prod.google.com [10.68.53.35])
	by zps77.corp.google.com with ESMTP id l6AM1JNO001114
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2007 15:02:17 -0700
Received: by ik-out-1112.google.com with SMTP id b35so1081035ika
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2007 15:02:16 -0700 (PDT)
In-Reply-To: <20070709.151522.52166816.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_145392_31260528.1184104936582
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 7/9/07, David Miller <davem@davemloft.net> wrote:
> From: Ranjit Manomohan <ranjitm@google.com>
> Date: Tue, 12 Jun 2007 16:53:21 -0700 (PDT)
>
> > Currently the HTB scheduler does not correctly account for TSO packets
> > which causes large inaccuracies in the bandwidth control when using TSO.
> > This patch allows the HTB scheduler to work with TSO enabled devices.
> >
> > Signed-off-by: Ranjit Manomohan <ranjitm@google.com>
>
> Your patch has much white-space damage and therefore won't apply,
> please fix this up and resubmit, thanks.
>

patch based on net-2.6.23 attached.

-Thanks,
Ranjit

------=_Part_145392_31260528.1184104936582
Content-Type: text/x-patch; name=htbtso.diff; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f3yx7hbz
Content-Disposition: attachment; filename="htbtso.diff"

Q3VycmVudGx5IHRoZSBIVEIgc2NoZWR1bGVyIGRvZXMgbm90IGNvcnJlY3RseSBhY2NvdW50IGZv
ciBUU08gcGFja2V0cwp3aGljaCBjYXVzZXMgbGFyZ2UgaW5hY2N1cmFjaWVzIGluIHRoZSBiYW5k
d2lkdGggY29udHJvbCB3aGVuIHVzaW5nIFRTTy4KVGhpcyBwYXRjaCBhbGxvd3MgdGhlIEhUQiBz
Y2hlZHVsZXIgdG8gd29yayB3aXRoIFRTTyBlbmFibGVkIGRldmljZXMuCgpTaWduZWQtb2ZmLWJ5
OiBSYW5qaXQgTWFub21vaGFuIDxyYW5qaXRtQGdvb2dsZS5jb20+CgpkaWZmIC0tZ2l0IGEvbmV0
L3NjaGVkL3NjaF9odGIuYyBiL25ldC9zY2hlZC9zY2hfaHRiLmMKaW5kZXggYzAzMTQ4Ni4uYjQx
N2E5NSAxMDA2NDQKLS0tIGEvbmV0L3NjaGVkL3NjaF9odGIuYworKysgYi9uZXQvc2NoZWQvc2No
X2h0Yi5jCkBAIC0xMjksMTUgKzEyOSwxMiBAQCBzdHJ1Y3QgaHRiX2NsYXNzIHsKIAkJCQkvKiBv
ZiB1bi5sZWFmIG9yaWdpbmFscyBzaG91bGQgYmUgZG9uZS4gKi8KIH07CiAKLS8qIFRPRE86IG1h
eWJlIGNvbXB1dGUgcmF0ZSB3aGVuIHNpemUgaXMgdG9vIGxhcmdlIC4uIG9yIGRyb3AgPyAqLwog
c3RhdGljIGlubGluZSBsb25nIEwyVChzdHJ1Y3QgaHRiX2NsYXNzICpjbCwgc3RydWN0IHFkaXNj
X3JhdGVfdGFibGUgKnJhdGUsCiAJCQkgICBpbnQgc2l6ZSkKIHsKIAlpbnQgc2xvdCA9IHNpemUg
Pj4gcmF0ZS0+cmF0ZS5jZWxsX2xvZzsKLQlpZiAoc2xvdCA+IDI1NSkgewotCQljbC0+eHN0YXRz
LmdpYW50cysrOwotCQlzbG90ID0gMjU1OwotCX0KKwlpZiAoc2xvdCA+IDI1NSkKKwkJcmV0dXJu
IChyYXRlLT5kYXRhWzI1NV0qKHNsb3QgPj4gOCkgKyByYXRlLT5kYXRhW3Nsb3QgJiAweEZGXSk7
CiAJcmV0dXJuIHJhdGUtPmRhdGFbc2xvdF07CiB9CiAKQEAgLTYwNiwxMyArNjAzLDE0IEBAICNl
bmRpZgogCQljbC0+cXN0YXRzLmRyb3BzKys7CiAJCXJldHVybiBORVRfWE1JVF9EUk9QOwogCX0g
ZWxzZSB7Ci0JCWNsLT5ic3RhdHMucGFja2V0cysrOworCQljbC0+YnN0YXRzLnBhY2tldHMgKz0K
KwkJCXNrYl9pc19nc28oc2tiKT9za2Jfc2hpbmZvKHNrYiktPmdzb19zZWdzOjE7CiAJCWNsLT5i
c3RhdHMuYnl0ZXMgKz0gc2tiLT5sZW47CiAJCWh0Yl9hY3RpdmF0ZShxLCBjbCk7CiAJfQogCiAJ
c2NoLT5xLnFsZW4rKzsKLQlzY2gtPmJzdGF0cy5wYWNrZXRzKys7CisJc2NoLT5ic3RhdHMucGFj
a2V0cyArPSBza2JfaXNfZ3NvKHNrYik/c2tiX3NoaW5mbyhza2IpLT5nc29fc2VnczoxOwogCXNj
aC0+YnN0YXRzLmJ5dGVzICs9IHNrYi0+bGVuOwogCXJldHVybiBORVRfWE1JVF9TVUNDRVNTOwog
fQpAQCAtNjYxLDggKzY1OSw5IEBAIHN0YXRpYyBpbnQgaHRiX3JlcXVldWUoc3RydWN0IHNrX2J1
ZmYgKnMKICAqIEluIHN1Y2ggY2FzZSB3ZSByZW1vdmUgY2xhc3MgZnJvbSBldmVudCBxdWV1ZSBm
aXJzdC4KICAqLwogc3RhdGljIHZvaWQgaHRiX2NoYXJnZV9jbGFzcyhzdHJ1Y3QgaHRiX3NjaGVk
ICpxLCBzdHJ1Y3QgaHRiX2NsYXNzICpjbCwKLQkJCSAgICAgaW50IGxldmVsLCBpbnQgYnl0ZXMp
CisJCQkgICAgIGludCBsZXZlbCwgc3RydWN0IHNrX2J1ZmYgKnNrYikKIHsKKwlpbnQgYnl0ZXMg
PSBza2ItPmxlbjsKIAlsb25nIHRva3MsIGRpZmY7CiAJZW51bSBodGJfY21vZGUgb2xkX21vZGU7
CiAKQEAgLTY5OCw3ICs2OTcsOCBAQCAjZGVmaW5lIEhUQl9BQ0NOVChULEIsUikgdG9rcyA9IGRp
ZmYgKyBjCiAJCS8qIHVwZGF0ZSBieXRlIHN0YXRzIGV4Y2VwdCBmb3IgbGVhdmVzIHdoaWNoIGFy
ZSBhbHJlYWR5IHVwZGF0ZWQgKi8KIAkJaWYgKGNsLT5sZXZlbCkgewogCQkJY2wtPmJzdGF0cy5i
eXRlcyArPSBieXRlczsKLQkJCWNsLT5ic3RhdHMucGFja2V0cysrOworCQkJY2wtPmJzdGF0cy5w
YWNrZXRzICs9IHNrYl9pc19nc28oc2tiKT8KKwkJCQkJc2tiX3NoaW5mbyhza2IpLT5nc29fc2Vn
czoxOwogCQl9CiAJCWNsID0gY2wtPnBhcmVudDsKIAl9CkBAIC04ODIsNyArODgyLDcgQEAgbmV4
dDoKIAkJICAgZ2l2ZXMgdXMgc2xpZ2h0bHkgYmV0dGVyIHBlcmZvcm1hbmNlICovCiAJCWlmICgh
Y2wtPnVuLmxlYWYucS0+cS5xbGVuKQogCQkJaHRiX2RlYWN0aXZhdGUocSwgY2wpOwotCQlodGJf
Y2hhcmdlX2NsYXNzKHEsIGNsLCBsZXZlbCwgc2tiLT5sZW4pOworCQlodGJfY2hhcmdlX2NsYXNz
KHEsIGNsLCBsZXZlbCwgc2tiKTsKIAl9CiAJcmV0dXJuIHNrYjsKIH0K
------=_Part_145392_31260528.1184104936582--
