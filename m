From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 4/5] ne: MIPS: Use platform_driver for ne on RBTX49XX
Date: Tue, 1 May 2007 07:31:34 +0100
Message-ID: <20070501063134.GA5183@linux-mips.org>
References: <20070501.002758.15250764.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org, jeff@garzik.org,
	sshtylyov@ru.mvista.com, akpm@linux-foundation.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:35705 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031682AbXEAMEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 08:04:24 -0400
Received: from localhost.localdomain ([127.0.0.1]:23976 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20022750AbXEAMEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 13:04:21 +0100
Content-Disposition: inline
In-Reply-To: <20070501.002758.15250764.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 12:27:58AM +0900, Atsushi Nemoto wrote:

> This patch lets RBTX49XX boards use generic platform_driver interface
> for the ne driver.
> 
> * Use platform_device to pass ioaddr and irq to the ne driver.
> * Remove unnecessary ifdefs for RBTX49XX from the ne driver.
> * Make the ne driver selectable on these boards regardless of CONFIG_ISA
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
