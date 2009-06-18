From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: do not bring device down when suspending
Date: Wed, 17 Jun 2009 18:53:58 -0700 (PDT)
Message-ID: <20090617.185358.33739264.davem@davemloft.net>
References: <20090617214145.GA27064@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edward_hsu@realtek.com.tw, aeriksson@fastmail.fm,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51091
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754820AbZFRBxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 21:53:55 -0400
In-Reply-To: <20090617214145.GA27064@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 17 Jun 2009 23:41:45 +0200

> Stopping all activity through ChipCmd and blindly acking the irqs
> is neither nice nor completely needed: the transition to low-power
> mode does enough work and it apparently keeps the device in a sane
> state.
> 
> Patch suggested by a fix for http://bugzilla.kernel.org/show_bug.cgi?id=9512
> 
> The rtl_shutdown path is kept unchanged so far.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Anders Eriksson <aeriksson@fastmail.fm>

Applied.
