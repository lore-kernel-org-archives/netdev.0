From: "David S. Miller" <davem@redhat.com>
Subject: Re: dev->destructor
Date: Tue, 06 May 2003 07:23:38 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030506.072338.39479306.davem@redhat.com>
References: <20030505130050.4b9868bb.shemminger@osdl.org>
	<20030506075808.388332C07F@lists.samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: rusty@rustcorp.com.au
In-Reply-To: <20030506075808.388332C07F@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Rusty Russell <rusty@rustcorp.com.au>
   Date: Tue, 06 May 2003 14:18:36 +1000
   
   It's logically consistent to make it implicit, and cuts out some
   code in the unload path.
   
   How's this?

This looks fine to me.

How hard would it be to make this completely consistent in that
no module code is ever invoked with modcount == 0?  By this I mean
keeping the implicit reference after modload succeeds, and then
calling ->cleanup() is valid once the count drops to '1'.
