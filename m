From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len space
Date: Sun, 30 Jul 2006 18:40:04 +0200
Message-ID: <m3fygjkpwb.fsf@defiant.localdomain>
References: <m3zmevqhgn.fsf@defiant.localdomain>
	<20060727164334.GA2779@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:42442 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S932366AbWG3QkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2006 12:40:07 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060727164334.GA2779@ms2.inr.ac.ru> (Alexey Kuznetsov's message of "Thu, 27 Jul 2006 20:43:34 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Alexey,

Can you clarify this for me, please?

Do the semantics (I'm not talking about bugs) allow skb passed
to dev->hard_header() (if defined) and then to dev->hard_start_xmit()
to have less link layer header space than dev->hard_header_len?

I.e., is dev->hard_header_len only advisory?
-- 
Krzysztof Halasa
