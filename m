From: "David S. Miller" <davem@redhat.com>
Subject: Re: ipsec 2.5.70 trouble
Date: Thu, 29 May 2003 14:14:10 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529.141410.85405194.davem@redhat.com>
References: <1054235155.596.9.camel@simulacron>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: aj@dungeon.inka.de
In-Reply-To: <1054235155.596.9.camel@simulacron>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andreas Jellinghaus <aj@dungeon.inka.de>
   Date: 29 May 2003 21:05:55 +0200
   
   but on the target machine (same lan), I see the
   packets encrypted, but where is that second packet in tcpdump
   comming from?

After we do the transformation, we stick it back into
the nework stack input to prevent stack exhaustion.

And yes it is on purpose and not changing.
