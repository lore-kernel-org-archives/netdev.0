From: Thomas Sailer <t.sailer@alumni.ethz.ch>
Subject: Re: [PATCH] (1/4) Update baycom drivers for 2.6
Date: 22 Sep 2003 15:55:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064238944.31276.9.camel@kronenbourg.scs.ch>
References: <20030919133750.4053f72c.shemminger@osdl.org>
	 <3F6CA3E3.9060909@pobox.com>  <20030920144812.0c587a12.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-hams@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030920144812.0c587a12.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2003-09-20 at 23:48, Stephen Hemminger wrote:

Patch 1-3 look good.

> patch 4 was replacing local random with get_random_bytes.
> Probably not a good idea since people seem to be paranoid
> about losing entropy ...

Yes, IMO not a good idea to use entropy for such a simple task.
The random numbers are used for the channel access algorithm, and
nothing bad happens if they are predictable.

Tom
