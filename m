From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.68] sysctl max_dgram_qlen permissions
Date: Sat, 03 May 2003 00:28:22 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030503.002822.34760030.davem@redhat.com>
References: <Pine.LNX.4.44.0305021508540.3694-100000@w-nivedita.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <Pine.LNX.4.44.0305021508540.3694-100000@w-nivedita.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Fri, 2 May 2003 15:41:06 -0700 (PDT)

   Currently the sysctl var net.unix.max_dgram_qlen has 
   0600 permissions..Need users to be able to read it..
   Dont see any reason not to(?).
   
Applied, thanks.
   
   --- sysctl_net_unix.c	Sat Apr 19 19:49:10 2003
   +++ sysctl_net_unix.c.new	Fri May  2 13:48:11 2003

Please use properly rooted patches in the future.
Ie. soemthing like:

   --- a/linux/net/unix/sysctl_net_unix.c.orig	Sat Apr 19 19:49:10 2003
   +++ b/linux/net/unix/sysctl_net_unix.c	Fri May  2 13:48:11 2003

Patches like yours don't work at all with the automated patch
scripts lots of us use to ease the burdon of applying lots
of patches.

In fact, even if I had changed into net/unix/ before applying
your patch, it would fail because there patch tries to patch
a file named sysctl_net_unix.c.new which of course does not
exist.

Please, this is very lazy and causes me to waste a lot of time fixing
up your patch which I should not have to do. :(
