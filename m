From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.21-rc2-mm2: drivers/net/wireless/libertas/debugfs.c addr
 bogosity
Date: Wed, 7 Mar 2007 15:00:57 -0800
Message-ID: <20070307150057.4e6342dc.akpm@linux-foundation.org>
References: <20070306004408.d3f6434d.akpm@linux-foundation.org>
	<20070307224116.GE3441@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36647 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945897AbXCGXEQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 18:04:16 -0500
In-Reply-To: <20070307224116.GE3441@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Mar 2007 23:41:16 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> On Tue, Mar 06, 2007 at 12:44:08AM -0800, Andrew Morton wrote:
> >...
> > Changes since 2.6.20-rc2-mm1:
> >...
> >  git-netdev-all.patch
> >...
> >  git trees
> >...
> 
> drivers/net/wireless/libertas/debugfs.c contains:
>   #define item_addr(n) ((u32) &((wlan_adapter *)0)->n)
> 
> This is wrong on 64bit architectures.

Is OK - it is simply yet another reimplementation of offsetof().  Hint.
