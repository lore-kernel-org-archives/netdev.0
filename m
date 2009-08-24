From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NET: llc, zero sockaddr_llc struct
Date: Sun, 23 Aug 2009 18:56:17 -0700 (PDT)
Message-ID: <20090823.185617.36449822.davem@davemloft.net>
References: <1250967535-30692-1-git-send-email-jirislaby@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	acme@ghostprotocols.net
To: jirislaby@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751252AbZHXB4J@vger.kernel.org>
In-Reply-To: <1250967535-30692-1-git-send-email-jirislaby@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jirislaby@gmail.com>
Date: Sat, 22 Aug 2009 20:58:55 +0200

> sllc_arphrd member of sockaddr_llc might not be set. Zero sllc
> before copying it to the above layers.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

I know it seems arbitrary, but could you please memset() on the
structure instead of using an empty initializer so that it's
consistent with how all other ->getname() implementations deal with
this issue?

It's easier to audit that way.

Thanks.
