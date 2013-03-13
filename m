From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 4/6] VXLAN: Fix vxlan stats handling.
Date: Wed, 13 Mar 2013 15:58:37 -0700
Message-ID: <20130313155837.59e20e25@nehalam.linuxnetplumber.net>
References: <1363214923-3353-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:58184 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932482Ab3CMW6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:58:42 -0400
Received: by mail-pb0-f53.google.com with SMTP id un1so1476452pbc.26
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 15:58:42 -0700 (PDT)
In-Reply-To: <1363214923-3353-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Mar 2013 15:48:43 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> Fixes bug in VXLAN code where is iptunnel_xmit() called with NULL
> dev->tstats.
> This bug was introduced in commit 6aed0c8bf7d2f389b (tunnel: use
> iptunnel_xmit() again).
> 
> Following patch fixes bug by setting dev->tstats. It uses ip_tunnel
> module code to share stats function.
> 
> CC: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
