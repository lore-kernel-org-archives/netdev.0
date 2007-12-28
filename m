From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [NEIGH] Remove unused method from include/net/neighbour.h
Date: Fri, 28 Dec 2007 17:56:46 +0200
Message-ID: <eb3ff54b0712280756m45c92c0bhc1298f6b428ac3ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_2362_13144567.1198857406891"
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:45623 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755176AbXL1P4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 10:56:48 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1950565fga.17
        for <netdev@vger.kernel.org>; Fri, 28 Dec 2007 07:56:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_2362_13144567.1198857406891
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,
It seems to me that neigh_is_valid() inline method from
include/net/neighbour.h can be removed since it is not used.

Though it can be considered as an API for future use, and
indeed we have neigh_is_connected() method in this same header (which is BTW
used only in one place, drivers/net/cxgb3/l2t.c), we can easily notice
that we don't have
any accessor method to check whether the neighbour is in NUD_IN_TIMER
(not to mention that we don't have methods to check the single neighbour states,
like NUD_REACHABLE or NUD_DELAY or the other ones). So for consistency
I suggest to
consider removing the neigh_is_valid() method.


Regards,
Rami Rosen

http://www.linux-foundation.org/en/Net:Network_Overview


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_2362_13144567.1198857406891
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_faqwnlvc0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L25laWdoYm91ci5oIGIvaW5jbHVkZS9uZXQvbmVpZ2hi
b3VyLmgKaW5kZXggMTE1OTBmMi4uYTlkZGEyOSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9uZXQvbmVp
Z2hib3VyLmgKKysrIGIvaW5jbHVkZS9uZXQvbmVpZ2hib3VyLmgKQEAgLTI5MiwxMCArMjkyLDYg
QEAgc3RhdGljIGlubGluZSBpbnQgbmVpZ2hfaXNfY29ubmVjdGVkKHN0cnVjdCBuZWlnaGJvdXIg
Km5laWdoKQogCXJldHVybiBuZWlnaC0+bnVkX3N0YXRlJk5VRF9DT05ORUNURUQ7CiB9CiAKLXN0
YXRpYyBpbmxpbmUgaW50IG5laWdoX2lzX3ZhbGlkKHN0cnVjdCBuZWlnaGJvdXIgKm5laWdoKQot
ewotCXJldHVybiBuZWlnaC0+bnVkX3N0YXRlJk5VRF9WQUxJRDsKLX0KIAogc3RhdGljIGlubGlu
ZSBpbnQgbmVpZ2hfZXZlbnRfc2VuZChzdHJ1Y3QgbmVpZ2hib3VyICpuZWlnaCwgc3RydWN0IHNr
X2J1ZmYgKnNrYikKIHsK
------=_Part_2362_13144567.1198857406891--
