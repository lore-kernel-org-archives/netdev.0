From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: 2.7 net driver stuff
Date: Thu, 25 Mar 2004 09:26:48 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1080167207.1115.5.camel@gaston>
References: <4061CC0F.6060201@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4061CC0F.6060201@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-03-25 at 04:57, Jeff Garzik wrote:
> An initial, quick FYI.  I'll be taking input for net drivers that can be 
> removed in 2.7.  Even some of the ancient ISA net drivers still have users,
> 
> Other stuff:
> * Would like to get rid of de4x5.c, but EISA support still has users 
> that appear to care :)

And I have an old pmac laptop for which tulip dies while de4x5 works, I
didn't figure out what's up yet.

> * pondering importing Donald's myson driver, replacing unmaintained 
> fealnx.c.  We have the new module_alias() stuff, which makes the 
> transition a bit easier.
> 
> 	Jeff
> 
-- 
Benjamin Herrenschmidt <benh@kernel.crashing.org>
