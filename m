From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Question regarding wanrouter module
Date: Fri, 23 Sep 2011 13:26:53 +0200
Message-ID: <20110923112653.GA27240@electric-eye.fr.zoreil.com>
References: <4E7C528F.4010303@freyther.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Holger Hans Peter Freyther <holger@freyther.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55864 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327Ab1IWL1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 07:27:53 -0400
Content-Disposition: inline
In-Reply-To: <4E7C528F.4010303@freyther.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Holger Hans Peter Freyther <holger@freyther.de> :
[...]
> Fast forward to today, Sangoma provides a wanrouter.ko as well (they didn't
> bother to change the symbol names or module name). I wonder if there are any
> plans to improve the situation, e.g. rename the kernel module, change symbols,
> or if there would be objections to trying to add functionality to the kernel
> wanrouter.ko again ?

There are objections to adding.

The kernel wanrouter code is almost empty. Afaiu it mostly contains a
wan setup API.

Is there a reason why the added functionalities could not go through the
generic hdlc kernel code (see drivers/net/wan/hdlc*) ?

-- 
Ueimor
