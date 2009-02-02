From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] [RESEND] iproute2 : invalid burst/cburst calculation
 with hrtimers
Date: Mon, 2 Feb 2009 10:07:42 -0800
Message-ID: <20090202100742.690e0c8d@extreme>
References: <200902021926.17768.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40742 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752725AbZBBSHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 13:07:50 -0500
In-Reply-To: <200902021926.17768.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2 Feb 2009 19:26:17 +0200
Denys Fedoryschenko <denys@visp.net.lb> wrote:

> ------------->
> iproute2 : invalid burst/cburst calculation with hrtimers
> 
> If hrtimers on, /proc/net/psched shows 4th variable 
> as 1000000000
> Because burst calculated by division rate to this variable, 
> it will be almost always zero. As result, we will get higher system 
> load on low rates, and on high rates shaper will not able to process 
> data. So it is kind of critical bugfix for systems with hrtimers.
> It is checked and proved. Core 2 Quad was not able to 
> shape 200Mbps, and gave only 180-190. It is more safe to set it 
> to 1000HZ. If user wants, he can set custom "env" HZ variable.
> 
> Signed-off-by: Denys Fedoryschenko <denys@visp.net.lb>
> ---
> 
> -------------------------------------------------------

I would rather this be converted to floating point.
