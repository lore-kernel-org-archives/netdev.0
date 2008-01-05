From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25] [NET]: Remove obsolete comment
Date: Sat, 5 Jan 2008 14:21:48 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801051418140.32403@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1603208230-1199535708=:32403"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57938 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509AbYAEMVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 07:21:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1603208230-1199535708=:32403
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

[PATCH] [NET]: Remove obsolete comment

It seems that ip_build_xmit is no longer used in here and
ip_append_data is used.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---

Hi Dave,

While reading some nearby code, I noticed this. I'm not 100%
sure if the removal is valid or not nor have interest to dig
it up from history but I suppose you know it better without
having to look it up from history :-).

 net/ipv4/ip_output.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 3dc0c12..e57de0f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1339,8 +1339,6 @@ static int ip_reply_glue_bits(void *dptr, char *to, int offset,
  *
  *	Should run single threaded per socket because it uses the sock
  *     	structure to pass arguments.
- *
- *	LATER: switch from ip_build_xmit to ip_append_*
  */
 void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *arg,
 		   unsigned int len)
-- 
1.5.0.6

---696243703-1603208230-1199535708=:32403--
