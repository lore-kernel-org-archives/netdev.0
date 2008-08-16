From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sat, 16 Aug 2008 17:59:43 +0200
Message-ID: <20080816155943.GD7519@ami.dom.local>
References: <20080815190905.M56388@visp.net.lb> <200808161613.59948.denys@visp.net.lb> <20080816142706.GC7519@ami.dom.local> <200808161828.49068.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:27467 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbYHPP6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2008 11:58:20 -0400
Received: by ug-out-1314.google.com with SMTP id c2so45887ugf.37
        for <netdev@vger.kernel.org>; Sat, 16 Aug 2008 08:58:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808161828.49068.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 16, 2008 at 06:28:48PM +0300, Denys Fedoryshchenko wrote:
> Triggered panic by "batch" shaper "reapply".
> 
> Aug 16 18:26:29 192.168.20.66 [ 2920.823068] BUG: unable to handle kernel 
> Aug 16 18:26:29 192.168.20.66 NULL pointer dereference
> Aug 16 18:26:29 192.168.20.66 at 00000000
> Aug 16 18:26:29 192.168.20.66 [ 2920.823068] IP:
> Aug 16 18:26:29 192.168.20.66 [<c013c083>] find_usage_forwards+0x7e/0x92
...

This seems to be a different bug. Did you run this earlier (before the
last two patches)? I'd prefer to fix this oops from the beginning of
this thread first, so it would be better to test these patches without
changing conditions.

Jarek P.
