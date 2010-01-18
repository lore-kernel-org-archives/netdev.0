From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v4] net: Introduce realloc_netdev_mq()
Date: Mon, 18 Jan 2010 20:41:55 +0100
Message-ID: <20100118194155.GA3157@del.dom.local>
References: <20100117003653.GA3073@del.dom.local>
 <C27F8246C663564A84BB7AB34397724218281B8382@IRVEXCHCCR01.corp.ad.broadcom.com>
 <20100117225703.GB3161@del.dom.local>
 <1263839388.9026.10.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:56599 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401Ab0ARTmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 14:42:02 -0500
Received: by fxm25 with SMTP id 25so832783fxm.21
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 11:42:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1263839388.9026.10.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 18, 2010 at 10:29:48AM -0800, Michael Chan wrote:
> It's an improvement over existing code to unconditionally allocate max
> tx queues.  To make further improvements, we'll have to experiment with
> calling pci_enable_msix() so early during ->probe().  I will look into
> it.  Thanks.

I guess it can wait; thanks for remembering, btw.

Jarek P.
