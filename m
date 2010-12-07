From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH 2.6.36 stable] vlan: Avoid hwaccel vlan
 packets when vid not used.
Date: Tue, 7 Dec 2010 11:50:19 -0800
Message-ID: <20101207195019.GP13189@kroah.com>
References: <1289251381-6671-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:38285 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754553Ab0LGUJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Dec 2010 15:09:23 -0500
Content-Disposition: inline
In-Reply-To: <1289251381-6671-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 08, 2010 at 01:23:01PM -0800, Jesse Gross wrote:
> Normally hardware accelerated vlan packets are quickly dropped if
> there is no corresponding vlan device configured.  The one exception
> is promiscuous mode, where we allow all of these packets through so
> they can be picked up by tcpdump.  However, this behavior causes a
> crash if we actually try to receive these packets.  This fixes that
> crash by ignoring packets with vids not corresponding to a configured
> device in the vlan hwaccel routines and then dropping them before they
> get to consumers in the network stack.
> 
> This patch applies only to 2.6.36 stable.  The problem was introduced
> in that release and is already fixed by larger changes to the vlan
> code in 2.6.37.

Applied, thanks.

greg k-h
