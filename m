From: Rostislav Lisovy <lisovy@gmail.com>
Subject: Re: [PATCH net-next] em_canid: Ematch rule to match CAN frames
 according to their CAN IDs
Date: Thu, 28 Jun 2012 17:35:28 +0200
Message-ID: <1340897728.6032.31.camel@lolumad>
References: <1340022131-7827-1-git-send-email-lisovy@gmail.com>
	 <4FEA169C.1070709@hartkopp.net>
	 <20120627093325.GB410@vandijck-laurijssen.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, lartc@vger.kernel.org,
	pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20120627093325.GB410@vandijck-laurijssen.be>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-06-27 at 11:33 +0200, Kurt Van Dijck wrote: 
> Oliver, Rostislav,
> 
> I was just looking into this. I think the matching itself
> may be simplified by eliminating checks 'that have already been made'.

Thank you for your remarks, I have removed all of the unnecessary
CAN_EFF_MASK masking.

Regards;
Rostislav 

