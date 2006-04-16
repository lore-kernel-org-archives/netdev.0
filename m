From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH][RFC] Security marking
Date: Sun, 16 Apr 2006 01:28:13 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0604160127010.16933@d.namei>
References: <Pine.LNX.4.64.0604160012500.16600@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:29390 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751122AbWDPF2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 01:28:16 -0400
Received: from megaweapon.nightmoose.net (HELO d.namei) ([66.92.66.197])
          (envelope-sender <jmorris@namei.org>)
          by mail3.sea5.speakeasy.net (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 16 Apr 2006 05:28:15 -0000
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0604160012500.16600@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 16 Apr 2006, James Morris wrote:

> +static inline void skb_copy_secmark(struct sk_buff *to, struct sk_buff *from)

(Btw, I know the last param here needs to be const, fixed locally).


-- 
James Morris
<jmorris@namei.org>
