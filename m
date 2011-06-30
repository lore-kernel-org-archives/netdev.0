From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: Re: possible bridge regression in "bridge: implement [add/del]_slave ops"?
Date: Thu, 30 Jun 2011 15:27:19 +0200
Message-ID: <201106301527.19539.alexander.stein@systec-electronic.com>
References: <201106301033.23997.alexander.stein@systec-electronic.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox687.server-home.net ([195.149.74.151]:46827 "EHLO
	webbox687.server-home.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab1F3N1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 09:27:22 -0400
In-Reply-To: <201106301033.23997.alexander.stein@systec-electronic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 30 June 2011 10:33:23 Alexander Stein wrote:
> BTW: I noticed that in 2.6.39.2 independently from this patch revert this
> bridge didn't show up RUNNING ifconfg. Is this intended? Another bridge I
> have, which doesn't use (R)STP, is shown as RUNNING like before.

This change was caused by commit 1faa4356a3bd89ea11fb92752d897cff3a20ec0e 
"bridge: control carrier based on ports online". It prevents the bridge from 
actually receiving/sending packets. Reverting restores the old behavior.
