From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] r8169: fix panic when using unlisted MAC
Date: Thu, 1 May 2008 17:12:24 -0400
Message-ID: <20080501211224.GA20212@gospo.usersys.redhat.com>
References: <20080428172209.GE26591@gospo.usersys.redhat.com> <20080501203249.GA3808@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ivecera@redhat.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52966 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764251AbYEAVM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2008 17:12:28 -0400
Content-Disposition: inline
In-Reply-To: <20080501203249.GA3808@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 01, 2008 at 10:32:49PM +0200, Francois Romieu wrote:
> Andy Gospodarek <andy@greyhouse.net> :
> [...]
> > When using the r8169 driver with an unlisted MAC, the system will
> > panic in rtl8169_get_mac_version since it will try to access tp->pci_dev
> > when it's unset.  Moving the call to set pci_dev earlier in
> > rtnl8169_init_one will resolve this and should not introduce any other
> > problems.
> 
> This change has already been committed in Linus's tree.
> 

Hmmm, apparently I need to communicate better with Ivan.... :-)

