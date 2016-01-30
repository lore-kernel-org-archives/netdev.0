From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net v2 0/4] net: add and use rx_nohandler stat counter
Date: Sat, 30 Jan 2016 13:16:48 -0500
Message-ID: <20160130181648.GP59058@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
 <1453996188-29965-1-git-send-email-jarod@redhat.com>
 <20160129.193751.27856238718097733.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, tom@herbertland.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160129.193751.27856238718097733.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 29, 2016 at 07:37:51PM -0800, David Miller wrote:
> From: Jarod Wilson <jarod@redhat.com>
> Date: Thu, 28 Jan 2016 10:49:44 -0500
> 
> > The network core tries to keep track of dropped packets, but some packets
> > you wouldn't really call dropped, so much as intentionally ignored, under
> > certain circumstances. One such case is that of bonding and team device
> > slaves that are currently inactive. Their respective rx_handler functions
> > return RX_HANDLER_EXACT (the only places in the kernel that return that),
> > which ends up tracking into the network core's __netif_receive_skb_core()
> > function's drop path, with no pt_prev set. On a noisy network, this can
> > result in a very rapidly incrementing rx_dropped counter, not only on the
> > inactive slave(s), but also on the master device, such as the following:
>  ...
> 
> Both my inbox and patchwork only show patch 2, 3, and 4.  Where is #1?

Crap. It seems I fat-fingered netdev@vger.kernel.org without the v in
front of ger. Will re-send in a sec, hopefully finallly not screwing it up
this time.

-- 
Jarod Wilson
jarod@redhat.com
