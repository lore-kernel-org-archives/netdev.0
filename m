From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix netlink address dumping in IPv4/IPv6
Date: Fri, 26 Mar 2010 20:36:27 -0700 (PDT)
Message-ID: <20100326.203627.215356664.davem@davemloft.net>
References: <4BACEB4F.9060900@trash.net>
	<20100326.202828.165365437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45795
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752811Ab0C0DgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 23:36:05 -0400
In-Reply-To: <20100326.202828.165365437.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 26 Mar 2010 20:28:28 -0700 (PDT)

> 
> Applied, thanks.

BTW, you encoded this patch in such a way that:

1) patchwork didn't even notice it

2) it made more work for me to apply it

Putting just the commit message and the patch itself
as an attachment isn't going to work.

It ought to be quite simple:

Mail headers:

1) If you wrote the patch the normal "From: " in your
   email takes care of everything.  Else add a new
   one at the top of the mail message body for the
   actual author.

2) Make "Subject: " be the commit message header line.
   Anything in leading "[]" brackets will be removed by
   the git tools so you can say things like "[PATCH]" and
   "[PATCH net-2.6]" there.

3) After any optional "From: " override for the patch author, the
   content of your email body should start with the commit message.

4) If you want to make more comments that don't end up into the commit
   message (like: "Dave this should go to -stable for 2.6.33 only")
   add a line with "---" three dashes then on the following lines say
   what you want to say

5) Then comes the patch.

This really should be trivial.

Don't use attachments, just:

--------------------------------------------------
From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH whatever] Commit header line

Commit message

---

Any extra side notes.

 net/ipv4/devinet.c  |    2 +-
 net/ipv6/addrconf.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 51ca946..3feb2b3 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1194,7 +1194,7 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct n
...
--------------------------------------------------

I really should be able to take your email and feed it
to "git am" and it should "just work".  I can't do that
with what you're giving me.
