From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] firmware: convert e100 driver to
	request_firmware()
Date: Sun, 15 Jun 2008 15:00:06 -0400
Message-ID: <485566B6.4030206@garzik.org>
References: <1213522966.26255.433.camel@pmac.infradead.org>	
	<48555677.7040209@garzik.org>	
	<3f9a31f40806151134n1b5e4de7m2ccd9c8a9e98cdb4@mail.gmail.com>
	<1213555326.26255.518.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jaswinder Singh <jaswinderlinux@gmail.com>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1213555326.26255.518.camel@pmac.infradead.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

David Woodhouse wrote:
> On Mon, 2008-06-16 at 00:04 +0530, Jaswinder Singh wrote:
>> driver source code will goto drivers directory and firmware will goto
>> firmware directory.
>> Please let us know, how can we keep them in same directory.
> 
> Realistically speaking, we can't.

Of course you can.  That's where we keep binary firmwares now -- with 
the drivers.

And, shockingly enough, it makes maintenance nice and easy to keep 
everything in one location.


> Although we'll preserve the option to
> build firmware blobs into the kernel image, the primary means of using
> them should be running 'make firmware_install' and having them put
> into /lib/firmware. It's better for them to be in the firmware/
> directory.

You have not built any logical connection with this statement.

Kernel modules are installed via 'make modules_install', and we don't 
have any special directory requirements for that.

There is absolutely no reason why 'make firmware_install' cannot work on 
firmwares in existing directories.

	Jeff



-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
