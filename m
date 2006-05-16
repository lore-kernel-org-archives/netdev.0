From: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Subject: Re: [-mm patch] drivers/net/s2io.c: make bus_speed[] static
Date: Tue, 16 May 2006 17:36:11 +0200
Message-ID: <20060516153611.GA13270@rhlx01.fht-esslingen.de>
References: <20060515005637.00b54560.akpm@osdl.org> <20060516153050.GC5677@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>,
	Ananda Raju <ananda.raju@neterion.com>, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.fht-esslingen.de ([129.143.116.10]:37250 "EHLO
	rhlx01.fht-esslingen.de") by vger.kernel.org with ESMTP
	id S1751235AbWEPPgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 11:36:12 -0400
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060516153050.GC5677@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, May 16, 2006 at 05:30:50PM +0200, Adrian Bunk wrote:
> This patch makes the needlessly global bus_speed[] static.

Is there a reason why you don't also constify it while you are at it?
Or is it because you want to do a series of static-only patches for now?

Andreas Mohr
