From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: adds a space before congestion string
Date: Fri, 11 Sep 2009 10:32:29 +0200
Message-ID: <4AAA0B1D.90402@gmail.com>
References: <20090910120416.6fd03d1f@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54956 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753580AbZIKIc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 04:32:27 -0400
In-Reply-To: <20090910120416.6fd03d1f@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> I am putting together release for 2.6.31 based tools.
> The only open issue is how to deal with the error handling in command=
s
> that do monitoring filtering.  Right now leaning towards the two sock=
et
> solution.
>=20
> So if you have anything else that you have been waiting for,
> please drop me a note.

Another patch would be nice too :

ss -io

ESTAB      0      0                                         55.225.18.1=
6:52668                                     55.225.18.187:49531
         sackbic wscale:2,6 rto:219 rtt:19.75/16.5 ato:40 cwnd:4 send 2=
=2E4Mbps rcv_space:5840

Note the 'sackbic' string, instead of sack bic ?

Thanks

[PATCH] ss: adds a space before congestion string

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/misc/ss.c b/misc/ss.c
index 651fe3b..9396468 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1302,7 +1302,7 @@ static void tcp_show_info(const struct nlmsghdr *=
nlh, struct inet_diag_msg *r)
 		}
=20
 		if (tb[INET_DIAG_CONG])
-			printf("%s", (char *) RTA_DATA(tb[INET_DIAG_CONG]));
+			printf(" %s", (char *) RTA_DATA(tb[INET_DIAG_CONG]));
=20
 		if (info->tcpi_options & TCPI_OPT_WSCALE)
 			printf(" wscale:%d,%d", info->tcpi_snd_wscale,
