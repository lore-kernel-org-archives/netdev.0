From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: smp_affinity, MSI-X and 2.6.21.1
Date: Mon, 07 May 2007 16:07:00 -0700
Message-ID: <1178579220.3819.1.camel@laptopd505.fenrus.org>
References: <463F91D3.3010000@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:55564 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754907AbXEGXJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 19:09:47 -0400
In-Reply-To: <463F91D3.3010000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-05-07 at 13:53 -0700, Rick Jones wrote:
> Folks -
> 
> Is it a bug, or a feature that after changing a device's smp_affinity via echo 
> "N" >> /proc/irq/M/smp_affinity that the new mask isn't visible via cat 
> /proc/irq/M/smp_affinity until after actual interrupts are taken?\

that's known and expected behavior

