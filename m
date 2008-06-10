From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6] [ipv4] remove unused declaration from include/net/tcp.h.
Date: Tue, 10 Jun 2008 16:14:24 +0300
Message-ID: <eb3ff54b0806100614o26981c8ao5b1fb952f7b843fa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_16314_16813190.1213103664863"
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:12526 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbYFJNO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 09:14:27 -0400
Received: by rv-out-0506.google.com with SMTP id k40so886315rvb.1
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2008 06:14:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_16314_16813190.1213103664863
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

- The tcp_unhash() method in /include/net/tcp.h is no more needed, as the
unhash method in tcp_prot structure is now inet_unhash (instead of
tcp_unhash in the
past); see tcp_prot structure in net/ipv4/tcp_ipv4.c.

- So, this patch removes tcp_unhash() declaration from include/net/tcp.h

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_16314_16813190.1213103664863
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fhaijfx40
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L3RjcC5oIGIvaW5jbHVkZS9uZXQvdGNwLmgKaW5kZXgg
NjMzMTQ3Yy4uZDQ0ODMxMCAxMDA2NDQKLS0tIGEvaW5jbHVkZS9uZXQvdGNwLmgKKysrIGIvaW5j
bHVkZS9uZXQvdGNwLmgKQEAgLTQzMyw3ICs0MzMsNiBAQCBleHRlcm4gc3RydWN0IHNrX2J1ZmYg
KgkJdGNwX21ha2Vfc3luYWNrKHN0cnVjdCBzb2NrICpzaywKIAogZXh0ZXJuIGludAkJCXRjcF9k
aXNjb25uZWN0KHN0cnVjdCBzb2NrICpzaywgaW50IGZsYWdzKTsKIAotZXh0ZXJuIHZvaWQJCQl0
Y3BfdW5oYXNoKHN0cnVjdCBzb2NrICpzayk7CiAKIC8qIEZyb20gc3luY29va2llcy5jICovCiBl
eHRlcm4gX191MzIgc3luY29va2llX3NlY3JldFsyXVsxNi00K1NIQV9ESUdFU1RfV09SRFNdOwo=

------=_Part_16314_16813190.1213103664863--
