From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.69] IPV4 should use dev_hold
Date: Wed, 07 May 2003 00:32:42 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030507.003242.104053566.davem@redhat.com>
References: <20030506075808.388332C07F@lists.samba.org>
	<20030506.072338.39479306.davem@redhat.com>
	<20030506153234.4907001f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030506153234.4907001f.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Tue, 6 May 2003 15:32:34 -0700

   While debugging possible changes to dev refcounting, discovered
   a couple of places in IPV4 that were directly incrementing rather
   than using the inline dev_hold.  Let's hide the implementation of
   net device ref counting so  future module ref count fixes will be easier.

Applied, thanks.  If you find any more, just send along
another patch :-)
