From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v5 2/2] Ethernet driver for the WIZnet W5100 chip
Date: Sat, 31 Mar 2012 11:46:05 +0200
Message-ID: <20120331094605.GA7876@electric-eye.fr.zoreil.com>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru> <1333090806-27988-2-git-send-email-msink@permonline.ru> <1333099431.19659.15.camel@edumazet-laptop> <20120331094014.GA7746@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Sinkovsky <msink@permonline.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120331094014.GA7746@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> The start_tx logic seems broken anyway: it claims it always can take
> packets until it is given one it can't process. The driver should rather
> do the opposite and stop queueing as soon as there is no guarantee for
> the next packet.

Forget it: the driver stops queuing in this path anyway.

-- 
Ueimor
