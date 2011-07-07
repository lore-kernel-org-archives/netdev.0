From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] e1000: always call e1000_check_for_link() on
 e1000_ce4100 MACs.
Date: Thu, 7 Jul 2011 07:10:49 -0700
Message-ID: <20110707141049.GD27648@kroah.com>
References: <1310044617-22978-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Dirk Brandewie <dirk.j.brandewie@intel.com>,
	netdev@vger.kernel.org, stable@kernel.org,
	Florian Fainelli <ffainelli@freebox.fr>
To: nschichan@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5.smtp.messagingengine.com ([66.111.4.29]:44114 "EHLO
	out5.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752807Ab1GGOLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 10:11:42 -0400
Content-Disposition: inline
In-Reply-To: <1310044617-22978-1-git-send-email-nschichan@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 07, 2011 at 03:16:57PM +0200, nschichan@freebox.fr wrote:
> From: Nicolas Schichan <nschichan@freebox.fr>
> 
> Interrupts about link lost or rx sequence errors are not reported by
> the ce4100 hardware, leading to transitions from link UP to link DOWN
> never being reported.
> 
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
> ---
>  drivers/net/e1000/e1000_main.c |   11 +++++++----
>  1 files changed, 7 insertions(+), 4 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
