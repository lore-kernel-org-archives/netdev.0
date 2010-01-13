From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Wed, 13 Jan 2010 22:09:08 +0100
Message-ID: <20100113210908.GA3065@del.dom.local>
References: <20100107185040.GB3208@del.dom.local>
 <4B466A26.5070506@majjas.com>
 <20100108074539.GA6205@ff.dom.local>
 <4B475FF9.7000702@majjas.com>
 <20100108212923.GA3078@del.dom.local>
 <4B47A81B.5040601@majjas.com>
 <4B4809EF.1070609@majjas.com>
 <20100109122830.GA4386@del.dom.local>
 <4B48CC2C.2090403@majjas.com>
 <4B4E2F89.2050606@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756352Ab0AMVJQ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B4E2F89.2050606@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2010 at 03:39:37PM -0500, Michael Breuer wrote:
> Just an FYI - 2.6.32.3 with alt 3 af_packet patch & sky2
> pskb_may_pull runs OK with DMAR (re)enabled and msi enabled.

Hmm... What a pity! It was such a useful debugging tool for
networking ;-) BTW, I'm not sure if "runs OK" means with or without
those DHCP drops & large packets you described.

Thanks,
Jarek P.
