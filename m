From: Jeff Dike <jdike@addtoit.com>
Subject: Re: drivers/infiniband/mlx/mad.c misplaced ;
Date: Thu, 16 Aug 2007 10:52:10 -0400
Message-ID: <20070816145210.GD6670@c2.user-mode-linux.org>
References: <20070815235825.GB17004@redhat.com> <1187224811.5906.55.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>, rolandd@cisco.com,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Paul Mundt <lethal@linux-sh.org>,
	isdn4linux@listserv.isdn4linux.de, mikep@linuxtr.net,
	netdev@vger.kernel.org, swen@vnet.ibm.com, linux390@de.ibm.com,
	linux-s390@vger.kernel.org,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	netfilter-devel@lists.netfilter.org, coreteam@netfilter.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761849AbXHPOyV@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1187224811.5906.55.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 05:40:11PM -0700, Joe Perches wrote:
> fs/hostfs/hostfs_user.c:        if(attrs->ia_valid & HOSTFS_ATTR_CTIME) ;

This one can be deleted, but I think I did it for documentation
reasons, to make it clear that ctime handling wasn't left out by
mistake.

				Jeff

-- 
Work email - jdike at linux dot intel dot com
