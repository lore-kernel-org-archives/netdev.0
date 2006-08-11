From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: the mystery that is sock_fasync
Date: Fri, 11 Aug 2006 17:35:13 +0400
Message-ID: <20060811133513.GA3983@ms2.inr.ac.ru>
References: <20060811.031516.38316536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:44185 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751114AbWHKNft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 09:35:49 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060811.031516.38316536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Did I miss some way that multiple file objects can point to the
> same socket inode?

Absolutely prohibited. Always was.

Apparently, sock_fasync() was cloned from tty_fasync(), that's the only
reason why it is so creepy.

Alexey
