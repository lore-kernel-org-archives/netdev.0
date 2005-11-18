From: Mark Lord <lkml@rtr.ca>
Subject: Re: [RFC: 2.6 patch] remove drivers/net/tulip/xircom_tulip_cb.c
Date: Fri, 18 Nov 2005 17:34:18 -0500
Message-ID: <437E56EA.8070103@rtr.ca>
References: <20051118033306.GP11494@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, tulip-users@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751106AbVKRWe1@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20051118033306.GP11494@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch removes the obsolete drivers/net/tulip/xircom_tulip_cb.c 
> driver.
> 
> Is there any reason why it should be kept?

Yes.  It is the only driver that works
without lockups on Xircom Cardbus cards.
Or so has been the case any time I've tried
the alternatives.

Is there any good reason to nuke it?
