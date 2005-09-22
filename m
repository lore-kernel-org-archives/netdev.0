From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH] bond_main.c: fix device deregistration in init exception path
Date: Thu, 22 Sep 2005 03:43:39 +0100
Message-ID: <20050922024339.GD7992@ftp.linux.org.uk>
References: <432D0612.7070408@gmail.com> <20050917233224.2d4b3652.akpm@osdl.org> <43321922.70707@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Florin Malita <fmalita@gmail.com>,
	linux-kernel@vger.kernel.org, ctindel@users.sourceforge.net,
	fubar@us.ibm.com, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965216AbVIVCnx@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <43321922.70707@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 21, 2005 at 10:38:26PM -0400, Jeff Garzik wrote:
> >+	rtnl_unlock();
> >+	rtnl_lock();
> >+
> 
> 
> Don't we want a schedule() or schedule_timeout(1) in between?

No.  rtnl_unlock() does the needed calls directly.
