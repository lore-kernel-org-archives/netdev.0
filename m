From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (1/4) Update baycom drivers for 2.6
Date: Sat, 20 Sep 2003 14:48:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030920144812.0c587a12.shemminger@osdl.org>
References: <20030919133750.4053f72c.shemminger@osdl.org>
	<3F6CA3E3.9060909@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: t.sailer@alumni.ethz.ch, linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F6CA3E3.9060909@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 20 Sep 2003 15:00:51 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> hum.  I seem to be missing patch 4/4...
> 
patch 4 was replacing local random with get_random_bytes.
Probably not a good idea since people seem to be paranoid
about losing entropy ...

A good future thing would be to make a kernel version of random()
for all drivers that uses get_random_bytes as a seed, but doesn't
drain the pool in normal use.
