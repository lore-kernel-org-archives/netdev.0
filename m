From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bnx2: fix poll_controller method so that proper
	structures are passed and all rx queues are checked
Date: Wed, 12 Nov 2008 20:09:42 -0500
Message-ID: <20081113010942.GA25768@localhost.localdomain>
References: <20081111173708.GC30481@hmsreliant.think-freely.org> <1226426364.23218.14.camel@HP1> <20081111185559.GD30481@hmsreliant.think-freely.org> <20081112.162359.114568315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, netdev@vger.kernel.org, jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57527 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbYKMBLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 20:11:53 -0500
Content-Disposition: inline
In-Reply-To: <20081112.162359.114568315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2008 at 04:23:59PM -0800, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 11 Nov 2008 15:58:03 -0500
> 
> > Fix bnx2 so that netpoll works properly.  Specifically:
> > 
> > 1) Fix parameters to bnx2_interrupt to be a struct bnx2_napi rather than a
> > struct net_device
> > 
> > 2) Fix poll_controller method to check every queue in the rx case so frames
> > aren't missed
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> This looks good, applied, thanks Neil!
> 
Thank you Dave!
Neil

