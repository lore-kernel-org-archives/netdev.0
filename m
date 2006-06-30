From: Dave Olson <olson@unixfolk.com>
Subject: Re: [PATCH 38 of 39] IB/ipath - More changes to support InfiniPath
 on PowerPC 970 systems
Date: Thu, 29 Jun 2006 17:28:51 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0606291725020.16720@osa.unixfolk.com>
References: <fa.KkJLjFz0MBUMS9nMlAyiBMrqx1g@ifi.uio.no>
 <fa./e2EfI5SsRLt5d/gFrBSOnDZpZ0@ifi.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bos@pathscale.com, akpm@osdl.org, rdreier@cisco.com,
	mst@mellanox.co.il, openib-general@openib.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from osa.unixfolk.com ([209.204.179.118]:51115 "EHLO
	osa.unixfolk.com") by vger.kernel.org with ESMTP id S964818AbWF3A3I
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 20:29:08 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <fa./e2EfI5SsRLt5d/gFrBSOnDZpZ0@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Jun 2006, David Miller wrote:

| From: Bryan O'Sullivan <bos@pathscale.com>
| Date: Thu, 29 Jun 2006 14:41:29 -0700
| 
| >  ipath_core-$(CONFIG_X86_64) += ipath_wc_x86_64.o
| > +ipath_core-$(CONFIG_PPC64) += ipath_wc_ppc64.o
| 
| Again, don't put these kinds of cpu specific functions
| into the infiniband driver.  They are potentially globally
| useful, not something only Infiniband might want to do.

The new code simply sets a flag as to whether instruction level
write barriers need to be used or not, it doesn't contain actual
code.

The older file (already accepted) does have some setup code, as well as
code setting flags, due to the fact that Bryan mentioned in his reply,
that this stuff simply doesn't yet exist in a generic form.   It's not
clear to me that it can ever be made to exist in a generic form that will
actually work on multiple architectures (or that there are enough users
to be worth trying).   We can make the attempt, but so far it's pretty
non-generic, in it's very nature.

Dave Olson
olson@unixfolk.com
http://www.unixfolk.com/dave
