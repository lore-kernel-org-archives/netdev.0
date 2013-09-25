From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Kernel Panic Sending Frames Using dev_queue_xmit()
Date: Thu, 26 Sep 2013 00:03:51 +0200
Message-ID: <20130925220351.GA4653@electric-eye.fr.zoreil.com>
References: <CAFu7c2V+gubfzG4HdWtPWJ-w2x3J-RToUT2mdahcKSgn66fDzg@mail.gmail.com>
 <1380133174.2222.13.camel@bwh-desktop.uk.level5networks.com>
 <CAFu7c2XDYR-SMiuqMxtqGhfM00nw8-h0Tr2uewN8+D1BptsayA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Merlin Davis <me.the.wizard@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38482 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888Ab3IYWD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 18:03:57 -0400
Content-Disposition: inline
In-Reply-To: <CAFu7c2XDYR-SMiuqMxtqGhfM00nw8-h0Tr2uewN8+D1BptsayA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Merlin Davis <me.the.wizard@gmail.com> :
[...]
>       err = net_xmit_eval(dev_queue_xmit(skb));

Macro expansion bug.

-- 
Ueimor
