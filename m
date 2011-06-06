From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Mon, 6 Jun 2011 22:33:54 +0200
Message-ID: <201106062233.54888.arnd@arndb.de>
References: <1307389540.2642.3.camel@edumazet-laptop> <201106062226.02635.arnd@arndb.de> <1307392352.2642.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:50999 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492Ab1FFUd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:33:57 -0400
In-Reply-To: <1307392352.2642.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 06 June 2011 22:32:32 Eric Dumazet wrote:
> In my case, I used latest bridge-utils tree, but compiled on a RHEL4
> machine :)
> 
> # ls -l /usr/include/linux/sockios.h
> -rw-r--r--  1 root root 5369 Mar 18  2002 /usr/include/linux/sockios.h
> # rpm -qf /usr/include/linux/sockios.h
> glibc-kernheaders-2.4-9.1.100.EL
> 
> Please note that pretty everything works on this 32bit distro machine,
> but a 64bit kernel.
> 

Ok, that is indeed an excellent reason to make it work.

	Arnd
