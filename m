From: "Yakov Lerner" <iler.ml@gmail.com>
Subject: attach additional value to skb
Date: Mon, 22 Oct 2007 22:03:47 +0200
Message-ID: <f36b08ee0710221303y5a846a27v1ebdc919db0f00ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:17991 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199AbXJVUDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 16:03:47 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1460998wah
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 13:03:47 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. How can I attach my 32-bit value to the skb in the
PRE_ROUTNIG hook such that FORWARD and POST_ROUTING
hooks can later access this value from the skb ?

Can I use sk_buff->cb for that ?

2.
I want to add my custom destructor to the skb, the function
pointer to be called at skb destruction time. Will the following
work:  if I push  address of my_destructor to the
sk-buff->destructor field,  and then when my_destructor
is called, I call the (saved)  old value of  sk-buff->destructor ?
Will this work ?

Yakov
