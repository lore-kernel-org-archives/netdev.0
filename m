From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net/bluetooth/lib.c: remove unneeded #defines
Date: Thu, 29 Sep 2005 22:14:54 +0400
Message-ID: <20050929181454.GD18132@mipter.zuzino.mipt.ru>
References: <20050928202856.GA27645@mipter.zuzino.mipt.ru> <1128012093.30743.20.camel@localhost.localdomain>
Reply-To: bluez-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maxim Krasnyansky <maxk@qualcomm.com>, bluez-devel@lists.sf.net,
	netdev@vger.kernel.org
Return-path: <bluez-devel-admin@lists.sourceforge.net>
To: Marcel Holtmann <marcel@holtmann.org>
Content-Disposition: inline
In-Reply-To: <1128012093.30743.20.camel@localhost.localdomain>
Sender: bluez-devel-admin@lists.sourceforge.net
Errors-To: bluez-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=bluez-devel>
List-Id: netdev.vger.kernel.org

On Thu, Sep 29, 2005 at 06:41:32PM +0200, Marcel Holtmann wrote:
> > -#include <linux/config.h>
> >  #include <linux/module.h>
> >  
> >  #include <linux/kernel.h>
> > -#include <linux/stddef.h>
> > -#include <linux/string.h>
> >  #include <asm/errno.h>
> >  
> >  #include <net/bluetooth/bluetooth.h>
> 
> thanks for the patch. Do you have more of them? If yes, then I like to
> cleanup this in one row and not step by step.

Looks like fcntl.h can be dropped too. I'll send a bigger patch.



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
