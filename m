From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: continue in debug mode, if probe fails
Date: Fri, 28 Aug 2015 11:16:38 +0530
Message-ID: <20150828054636.GA2667@hariprasad-pc.asicdesigners.com>
References: <1440608435-12039-1-git-send-email-hariprasad@chelsio.com>
 <20150827191433.GP13535@indiana.gru.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, leedom@chelsio.com,
	nirranjan@chelsio.com
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11810 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750989AbbH1Fqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:46:47 -0400
Content-Disposition: inline
In-Reply-To: <20150827191433.GP13535@indiana.gru.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 16:14:34 -0300, Thadeu Lima de Souza Cascardo wrote:
> On Wed, Aug 26, 2015 at 10:30:35PM +0530, Hariprasad Shenai wrote:
> > If adapter is flashed with incorrect firmware, probe can fail.
> > If probe fails, continue in debug mode, so one can also use the debug
> > interface to update the firmware via ethtool.
> > 
> > Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> 
> What do you mean by incorrect firmware? I know the driver can cope with older
> firmware if force_old_init is used, for example. Isn't it possible to detect
> those old firmware versions and do the same as force_old_init does?
> 
> Cascardo.
Will add a code to check and upgrade for older FW which are not supported anymore.
