From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70] acenic -- update to use alloc_etherdev
Date: Wed, 11 Jun 2003 21:04:45 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611.210445.21901735.davem@redhat.com>
References: <20030611144249.7cd63c1c.shemminger@osdl.org>
	<m3y90845nu.fsf@trained-monkey.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jes@wildopensource.com
In-Reply-To: <m3y90845nu.fsf@trained-monkey.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jes Sorensen <jes@wildopensource.com>
   Date: 11 Jun 2003 18:21:09 -0400

   >>>>> "Stephen" == Stephen Hemminger <shemminger@osdl.org> writes:
   
   Stephen> Updated acenic driver to use alloc_etherdev to hold private
   Stephen> data structure.  Uses register_netdev() to get the name right
   Stephen> this time ;-)
   
   Please provide a compat macro for 2.4.18 and younger as well.

How actively are you maintaining acenic. Jes?  :-)  This is
a very serious question, I haven't seen a 2.5.x change go back
to 2.4.x since it's inception.

All this compat nonsense is becoming useless.  Other drivers
fair just fine 2.4.x/2.5.x without all this ifdef mumbo-jumbo
that litters acenic.c and makes it nearly impossible to read.

In fact all these localized compat macros make acenic.c HARDER
to maintain.
