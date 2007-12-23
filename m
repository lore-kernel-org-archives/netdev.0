From: "David Shwatrz" <dshwatrz@gmail.com>
Subject: Re: [PATCH net-2.6][NEIGH] Updating affected neighbours when about MAC address change
Date: Sun, 23 Dec 2007 14:24:00 +0200
Message-ID: <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com>
References: <31436f4a0712230341x5a0abf08q7e6f7917ba7e38f0@mail.gmail.com>
	 <20071223.211126.118866275.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5201_4127844.1198412640247"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "=?BIG5?B?WU9TSElGVUpJIEhpZGVha2kgLyCmTsPDrV6p+g==?="
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:5697 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520AbXLWMYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 07:24:08 -0500
Received: by wa-out-1112.google.com with SMTP id v27so1919559wah.23
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2007 04:24:07 -0800 (PST)
In-Reply-To: <20071223.211126.118866275.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_5201_4127844.1198412640247
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
Oop, I am TWICE sorry ! I wrongly attached a wrong, empty file.
Attached here is the patch.

Regarding your answer;  I accept it and I will soon send a revised
version of this patch (making changes to
 arp_netdev_event() and ndisc_netdev_event().)
I had  IPv4 in mind, there is no reason that it will no be also in IPv6.

Regads,
David Shwatrz



On Dec 23, 2007 2:11 PM, YOSHIFUJI Hideaki / 吉藤英明
<yoshfuji@linux-ipv6.org> wrote:
> In article <31436f4a0712230341x5a0abf08q7e6f7917ba7e38f0@mail.gmail.com> (at Sun, 23 Dec 2007 13:41:36 +0200), "David Shwatrz" <dshwatrz@gmail.com> says:
>
> > I had written a small patch to neigh_changeaddr() in net/core/neighbour.c
> > against the 2.6 git net tree, which sends a gratuitous ARP to update
> > the list of
> > all the involved neighbours with the change of MAC address.
> > The patch is for neigh_changeaddr() only.
>
> Though I can see no patch, but I disagree. ;-)
> I do think you should change arp_netdev_event() and ndisc_netdev_event().
>
> --yoshfuji
>

------=_Part_5201_4127844.1198412640247
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fajjutso0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL25laWdoYm91ci5jIGIvbmV0L2NvcmUvbmVpZ2hib3VyLmMK
aW5kZXggMjliOGVlNC4uZGRlYWU4MiAxMDA2NDQKLS0tIGEvbmV0L2NvcmUvbmVpZ2hib3VyLmMK
KysrIGIvbmV0L2NvcmUvbmVpZ2hib3VyLmMKQEAgLTM2LDYgKzM2LDkgQEAKICNpbmNsdWRlIDxs
aW51eC9zdHJpbmcuaD4KICNpbmNsdWRlIDxsaW51eC9sb2cyLmg+CiAKKyNpbmNsdWRlIDxsaW51
eC9pbmV0ZGV2aWNlLmg+CisjaW5jbHVkZSA8bmV0L2FycC5oPgorCiAjZGVmaW5lIE5FSUdIX0RF
QlVHIDEKIAogI2RlZmluZSBORUlHSF9QUklOVEsoeC4uLikgcHJpbnRrKHgpCkBAIC0yMjgsOSAr
MjMxLDI2IEBAIHN0YXRpYyB2b2lkIG5laWdoX2ZsdXNoX2RldihzdHJ1Y3QgbmVpZ2hfdGFibGUg
KnRibCwgc3RydWN0IG5ldF9kZXZpY2UgKmRldikKIAogdm9pZCBuZWlnaF9jaGFuZ2VhZGRyKHN0
cnVjdCBuZWlnaF90YWJsZSAqdGJsLCBzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQogeworCXN0cnVj
dCBpbl9kZXZpY2UgKmluX2RldjsKIAl3cml0ZV9sb2NrX2JoKCZ0YmwtPmxvY2spOwogCW5laWdo
X2ZsdXNoX2Rldih0YmwsIGRldik7CiAJd3JpdGVfdW5sb2NrX2JoKCZ0YmwtPmxvY2spOworCSAK
KwkvKiBTZW5kIGEgZ3JhdHVpdG91cyBBUlAgdG8gdGhlIG5laWdoYm91cnMgdG8gdXBkYXRlIHRo
ZWlyIGFycCB0YWJsZXMgKi8KKwkKKwlyY3VfcmVhZF9sb2NrKCk7CisJaW5fZGV2ID0gX19pbl9k
ZXZfZ2V0X3JjdShkZXYpOworCWlmIChpbl9kZXYgPT0gTlVMTCkKKwkJZ290byBvdXQ7CisJaWYg
KGluX2Rldi0+aWZhX2xpc3QpCisJCQorCWFycF9zZW5kKEFSUE9QX1JFUVVFU1QsIEVUSF9QX0FS
UCwgCisJCSBpbl9kZXYtPmlmYV9saXN0LT5pZmFfYWRkcmVzcywKKwkJIGRldiwgCisJCSBpbl9k
ZXYtPmlmYV9saXN0LT5pZmFfYWRkcmVzcywKKwkJIE5VTEwsIGRldi0+ZGV2X2FkZHIsIE5VTEwp
Oworb3V0OgorCXJjdV9yZWFkX3VubG9jaygpOwogfQogCiBpbnQgbmVpZ2hfaWZkb3duKHN0cnVj
dCBuZWlnaF90YWJsZSAqdGJsLCBzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQo=
------=_Part_5201_4127844.1198412640247--
