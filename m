From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Mon, 14 Mar 2005 21:14:59 -0800
Message-ID: <bd1c90987d5e22481f0fa2ac3f63ced3@pobox.com>
References: <200503142023.j2EKNMDD027705@guinness.s2io.com>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "<netdev@oss.sgi.com>" <netdev@oss.sgi.com>,
        "<leonid@neterion.com>" <leonid@neterion.com>,
        "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: <200503142023.j2EKNMDD027705@guinness.s2io.com>
To: "<alex@neterion.com>" <alex@neterion.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Mar 14, 2005, at 12:22 PM, Alex Aizman wrote:

> HAL-based
> =========
> Most Neterion drivers are HAL (Hardware Abstraction Layer) based. This 
> is
> always a curse and blessing; in our experience this was the latter by 
> a big
> margin. While the current "s2io" driver in the kernel doesn't share 
> HAL code
> with other driver, the "xge" driver is HAL-based.

e1000 and ixgb are HAL-based, which is why there is always push back 
when someone in the community modifies *_hw.[ch].  I'd hate to see more 
of this in the kernel, but I can definitely relate to the "testing 
across multiple OSes" gain.

Here's an (old?) idea: remember the NDIS-wrapper project?  I think the 
reverse is much more interesting.  A linux-wrapper takes a plain old 
Linux driver and wraps it with what ever is needed to make it an NDIS 
driver.  Or FreeBSD, or whatever.  Let's pretend this is trivial for a 
second.  What do we gain?  1) one clean Linux driver to maintain, 2) 
testability on other OSes, and 3) access to other OSes' certification 
kits.  Licensing is clean: the Linux driver is GPL and the 
linux-wrapper code is GPL.  Can't the world revolve around Linux and 
let everyone else be burdened with the abstraction layer overhead?

-scott
