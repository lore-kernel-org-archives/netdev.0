From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [9/9][PATCH 2.6] Restructure reset code
Date: Mon, 14 Jun 2004 12:03:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040614100326.GA32763@k3.hellgate.ch>
References: <20040602115920.GA17634@k3.hellgate.ch> <40BE2DE0.4040102@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <40BE2DE0.4040102@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 02 Jun 2004 15:43:28 -0400, Jeff Garzik wrote:
> Roger Luethi wrote:
> >Restructure code to make it easier to maintain.
[...]
> Rejected, two reasons:
> 
> 1) dev->dev_addr[] should be loaded from eeprom only once, at probe 
> time, not once for each hw init.  [this value should be written to the 
> chip's MAC address registers upon each dev->open() call]
> 
> 2) Your "Note:" worries me...  why not deal with this now?  :)

I addressed your concerns in my June 2 reply, but the patch didn't
get merged. Meanwhile, I am maintaining a growing queue of via-rhine
patches that need review and wider testing -- what is missing to move
forward in -mm?

Roger
