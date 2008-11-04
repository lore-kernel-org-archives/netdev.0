From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: #ifdef ->sk_security
Date: Tue, 4 Nov 2008 08:17:43 +0300
Message-ID: <20081104051743.GA6157@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:54283 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbYKDFO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 00:14:26 -0500
Received: by nf-out-0910.google.com with SMTP id d3so1167632nfc.21
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2008 21:14:24 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/sock.h |    2 ++
 1 file changed, 2 insertions(+)

--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -271,7 +271,9 @@ struct sock {
 	struct sk_buff		*sk_send_head;
 	__u32			sk_sndmsg_off;
 	int			sk_write_pending;
+#ifdef CONFIG_SECURITY
 	void			*sk_security;
+#endif
 	__u32			sk_mark;
 	/* XXX 4 bytes hole on 64 bit */
 	void			(*sk_state_change)(struct sock *sk);
