From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] wrong ENETDOWN in af_packet?
Date: Thu, 06 Mar 2003 10:31:42 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030306.103142.58817243.davem@redhat.com>
References: <20030305141123.GA16699@ally.lammerts.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com, alan@lxorguk.ukuu.org.uk
Return-path: <netdev-bounce@oss.sgi.com>
To: eric@lammerts.org
In-Reply-To: <20030305141123.GA16699@ally.lammerts.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Eric Lammerts <eric@lammerts.org>
   Date: Wed, 5 Mar 2003 15:11:23 +0100
   
   The reason is that (in af_packet.c) packet_notifier(NETDEV_DOWN) sets
   sk->err to ENETDOWN, but packet_notifier(NETDEV_UP) doesn't clear it.
   Is this behaviour deliberate?

Yes the behavior is deliberate.  You want to be aware of the
event.  Just because the opposite event has occurred afterwards
doesn't mean the first event didn't happen :-)
