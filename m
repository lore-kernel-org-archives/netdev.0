From: "David S. Miller" <davem@redhat.com>
Subject: Re: dev->destructor
Date: Tue, 06 May 2003 20:58:18 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030506.205818.88490065.davem@redhat.com>
References: <20030506.072338.39479306.davem@redhat.com>
	<20030507035148.2C97F2C0C4@lists.samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: rusty@rustcorp.com.au
In-Reply-To: <20030507035148.2C97F2C0C4@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Rusty Russell <rusty@rustcorp.com.au>
   Date: Wed, 07 May 2003 12:50:07 +1000
   
   But that's a sideshow: you'd *still* want an extra refcount around the
   call to module_init().
 ...   
   Now, grabbing a similar reference when deleting a module might make
   sense, but it's actually kinda pointless when you look at the code.

Indeed, forget my idea ;-)
