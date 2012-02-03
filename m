From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Implement IP_UNICAST_IF socket option.
Date: Thu, 02 Feb 2012 20:50:44 -0500 (EST)
Message-ID: <20120202.205044.565511915004327213.davem@davemloft.net>
References: <1328219828.2480.32.camel@edumazet-laptop>
	<CAEU2+vrgxzTmiHWs-kVoKeu2_DcFZQBjCXwQfQ8dms5O6+Larg@mail.gmail.com>
	<CAOdseAOsGOD2bxOwQLZPq6KhL5xN9J81=d1tQWEULDZwxD9UxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ehoover@mines.edu, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shawn.lu@ericssion.com
To: xiaoclu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48019 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615Ab2BCBuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 20:50:51 -0500
In-Reply-To: <CAOdseAOsGOD2bxOwQLZPq6KhL5xN9J81=d1tQWEULDZwxD9UxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xiaochun Lu <xiaoclu@gmail.com>
Date: Thu, 2 Feb 2012 17:19:11 -0800

> Hi, Erich E. Hoover:
> 
> Can you give more detail on why we need invent another binding to
> device option in your patch log?  Why SO_BINDTODEVICE or IP_PKTINFO
> can't server your need?

Windows apps via wine will make use of this, and you can't just use
bind()'ing or IP_PKTINFO because the former doesn't work on broadcast
addreses and the latter might be used by the wine application at the
same time as IP_UNICAST_IF.

He explained this fully in his previous patch discussion, DO NOT repeat
this whole discussion it's a waste of time.
