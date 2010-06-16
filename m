From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: mpd client timeouts (bisected) 2.6.35-rc3
Date: Wed, 16 Jun 2010 03:01:22 -0700 (PDT)
Message-ID: <alpine.DEB.2.01.1006160255070.3964@bogon.housecafe.de>
References: <20100612102802.GA1782@arch.tripp.de> <20100612.145835.123986343.davem@davemloft.net> <4C149147.3080808@intel.com> <4C15414E.5090201@intel.com> <20100613205922.GA1806@arch.tripp.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, alex.shi@intel.com,
	tim.c.chen@intel.com
To: "markus@trippelsdorf.de" <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:62703 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555Ab0FPKBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 06:01:25 -0400
In-Reply-To: <20100613205922.GA1806@arch.tripp.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Jun 2010 at 22:59, markus@trippelsdorf.de wrote:
> This solves the problem here. Thanks.

Not sure if this is related, but I've noticed connection timeouts and 
connections going in FIN_WAIT2 state (most of them SSH tunnels) with 
2.6.35. Going back to 2.6.34 or applying John's (and Eric's) patch 
does seem to fix this issue.

Thanks,
Christian.
-- 
BOFH excuse #168:

le0: no carrier: transceiver cable problem?
