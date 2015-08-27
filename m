From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: Re: [PATCH net-next] cxgb4: continue in debug mode, if probe fails
Date: Thu, 27 Aug 2015 16:14:34 -0300
Message-ID: <20150827191433.GP13535@indiana.gru.redhat.com>
References: <1440608435-12039-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, leedom@chelsio.com,
	nirranjan@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37496 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752078AbbH0TOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2015 15:14:42 -0400
Content-Disposition: inline
In-Reply-To: <1440608435-12039-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2015 at 10:30:35PM +0530, Hariprasad Shenai wrote:
> If adapter is flashed with incorrect firmware, probe can fail.
> If probe fails, continue in debug mode, so one can also use the debug
> interface to update the firmware via ethtool.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

What do you mean by incorrect firmware? I know the driver can cope with older
firmware if force_old_init is used, for example. Isn't it possible to detect
those old firmware versions and do the same as force_old_init does?

Cascardo.
