From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 3/9] tunnel: introduce udp_tun_rx_dst()
Date: Thu, 20 Aug 2015 18:56:00 +0200
Message-ID: <20150820165600.GC8475@pox.localdomain>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
 <1439845905-31666-4-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34188 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbbHTQ4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 12:56:03 -0400
Received: by wicne3 with SMTP id ne3so21432614wic.1
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 09:56:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1439845905-31666-4-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/15 at 02:11pm, Pravin B Shelar wrote:
> Introduce function udp_tun_rx_dst() to initialize tunnel dst on
> receive path.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> Reviewed-by: Jesse Gross <jesse@nicira.com>

This looks great but conflicts with Jiri Benc's IPv6 series. Can we
rebase this on top of his work so we get IPv6 support in the new
helpers from the beginning?
