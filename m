From: "David S. Miller" <davem@redhat.com>
Subject: Re: comment about struct tcp_tw_bucket in struct sock
Date: Wed, 14 May 2003 13:02:32 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030514.130232.88490119.davem@redhat.com>
References: <20030514192305.GB31303@Wotan.suse.de>
	<20030514.123421.85395571.davem@redhat.com>
	<20030514195731.GC31303@Wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olh@suse.de, marcelo@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20030514195731.GC31303@Wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Wed, 14 May 2003 21:57:31 +0200

   When they cut'n'paste structures they're completely on their own ...
   
Depends upon who's willing to support them.

   I hope you will never let stop such an omnious third party module
   you from doing any bug fix or optimization.
   
Aha, you're right and _I_ don't need to worry about this.  I'm merely
saying some vendor's _might_. :-)

But see, since it only matters in the main kernel, every attempt to
change the layout of struct sock will go through me before it hits the
vanilla tree, so as a result I'll catch such problems and we thus have
no problems :-)

You can't have it both ways Andi, either we care about arbitrary third
parties do or we don't.
