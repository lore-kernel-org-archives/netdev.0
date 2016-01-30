From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 17:18:40 -0800 (PST)
Message-ID: <20160129.171840.780387494991424217.davem@davemloft.net>
References: <CALx6S34KtC4kkjzchY5Xs4QapD7FMqxShwEDST0Q_bZgDRicmQ@mail.gmail.com>
	<20160129235800.GH17127@oracle.com>
	<CALx6S37KgEPorPp4T4gh8xatsPUTOe=wuhG4fzqx8U35a9O3KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, eric.dumazet@gmail.com,
	mwdalton@google.com, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41274 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbcA3BSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 20:18:44 -0500
In-Reply-To: <CALx6S37KgEPorPp4T4gh8xatsPUTOe=wuhG4fzqx8U35a9O3KA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Fri, 29 Jan 2016 16:47:46 -0800

> Seems like it might be just as well to pull up a fixed number of
> bytes (ixgbe want min of 60 bytes),

This is precisely what we were trying to move away from, please
don't regress back to that.
