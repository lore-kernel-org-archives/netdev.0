From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: [bk patches] net driver updates
Date: Tue, 26 Aug 2003 10:17:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030826171754.GD16831@matchmail.com>
References: <20030817183137.GA18521@gtf.org> <20030823154231.A11381@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, torvalds@osdl.org,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20030823154231.A11381@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Aug 23, 2003 at 03:42:31PM +0200, Francois Romieu wrote:
> Jeff Garzik <jgarzik@pobox.com> :
> [net-drivers-2.6 update]
> >  drivers/net/sis190.c              | 2094 +++++++++++++++++++++++++++++---------
> 
> 
> synchronize_irq() requires an argument when built with CONFIG_SMP.

Shouldn't it also require it for the UP case?  Or is this one of those
subtle things that tells you it's not working on SMP?
