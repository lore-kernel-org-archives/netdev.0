From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] r8169: revert "Handle rxfifo errors on 8168 chips"
Date: Tue, 09 Nov 2010 08:27:06 -0800 (PST)
Message-ID: <20101109.082706.226770210.davem@davemloft.net>
References: <20101108232305.GA13720@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, a.radke@arcor.de, mjg@redhat.com,
	daniel.blueman@gmail.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48460
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752706Ab0KIQ0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 11:26:42 -0500
In-Reply-To: <20101108232305.GA13720@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 9 Nov 2010 00:23:05 +0100

> The original patch helps under obscure conditions (no pun) but
> some 8168 do not like it. The change needs to be tightened with
> a specific 8168 version.
> 
> This reverts commit 801e147cde02f04b5c2f42764cd43a89fc7400a2.
> 
> Regression at https://bugzilla.kernel.org/show_bug.cgi?id=20882
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Andreas Radke <a.radke@arcor.de>
> Cc: Matthew Garrett <mjg@redhat.com>
> Cc: Daniel J Blueman <daniel.blueman@gmail.com>

Applied.
