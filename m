From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: mmotm 2008-09-08-18-32 uploaded
Date: Tue, 9 Sep 2008 08:03:09 -0700
Message-ID: <20080909080309.3104a54c.randy.dunlap@oracle.com>
References: <200809090135.m891ZHiW020337@imap1.linux-foundation.org>
	<48C6429A.1040809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, romieu@fr.zoreil.com
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:29670 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbYIIPEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 11:04:09 -0400
In-Reply-To: <48C6429A.1040809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 09 Sep 2008 11:32:10 +0200 Jiri Slaby wrote:

> akpm@linux-foundation.org napsal(a):
> > The mm-of-the-moment snapshot 2008-09-08-18-32 has been uploaded to
> 
> Hi,
> 
> CONFIG_MII=n
> CONFIG_R8169=y
> 
> causes:
> drivers/built-in.o: In function `rtl8169_gset_xmii':
> r8169.c:(.text+0x8b4ec): undefined reference to `mii_ethtool_gset'
> 
> R8169 should depend on MII?
> --

It should select MII.  That should change CONFIG_MII to =y.

---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
