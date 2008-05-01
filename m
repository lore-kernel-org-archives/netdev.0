From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix panic when using unlisted MAC
Date: Thu, 1 May 2008 22:32:49 +0200
Message-ID: <20080501203249.GA3808@electric-eye.fr.zoreil.com>
References: <20080428172209.GE26591@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54191 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760037AbYEAUwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 16:52:47 -0400
Content-Disposition: inline
In-Reply-To: <20080428172209.GE26591@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> :
[...]
> When using the r8169 driver with an unlisted MAC, the system will
> panic in rtl8169_get_mac_version since it will try to access tp->pci_dev
> when it's unset.  Moving the call to set pci_dev earlier in
> rtnl8169_init_one will resolve this and should not introduce any other
> problems.

This change has already been committed in Linus's tree.

-- 
Ueimor
