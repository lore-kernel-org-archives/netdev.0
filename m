From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH v2] defxx: fix build warning
Date: Mon, 25 Jan 2016 15:26:59 +0000 (GMT)
Message-ID: <alpine.LFD.2.20.1601251526270.7055@eddie.linux-mips.org>
References: <1453707320-30556-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:37484 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757333AbcAYP1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 10:27:02 -0500
Received: (from localhost user: 'macro', uid#1010) by eddie.linux-mips.org
        with ESMTP id S27011386AbcAYP1AAS2g7 (ORCPT
        <rfc822;netdev@vger.kernel.org> + 1 other);
        Mon, 25 Jan 2016 16:27:00 +0100
In-Reply-To: <1453707320-30556-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Jan 2016, Sudip Mukherjee wrote:

> We are getting many build warnings about:
> 'bar_start' may be used uninitialized
> and
> 'bar_len' may be used uninitialized
> 
> They are not actually uninitialized as dfx_get_bars() will initialize
> them properly. But still lets have them initialized just to satisfy the
> compiler (gcc 4.8.2).
> 
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> ---

Acked-by: Maciej W. Rozycki <macro@linux-mips.org>

 Thanks,

  Maciej
