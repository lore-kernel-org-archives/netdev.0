From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] minor socket ioctl cleanup for 2.5.30
Date: Thu, 08 Aug 2002 08:33:20 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020808.083320.100990288.davem@redhat.com>
References: <Mutt.LNX.4.44.0208081018410.16830-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, willy@debian.org
Return-path: <owner-netdev@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0208081018410.16830-100000@blackbird.intercode.com.au>
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Thu, 8 Aug 2002 10:24:19 +1000 (EST)

   Suggested by Matthew Wilcox, the patch below consolidates FIOSETOWN etc. 
   ioctl handling into the socket layer, making it common for all sockets.

Do we really want to do this?  What if some socket family either
doesn't want to support it or wants to handle it differently?
   
   Btw, is af_wanpipe.c likely to stay in the tree?  It doesn't seem to be 
   used anymore.
   
I have no idea.  Ask the WAN people :-)
