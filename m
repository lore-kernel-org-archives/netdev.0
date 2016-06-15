From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH iproute2] tc: let m_ipt work with new iptables API
 headers
Date: Tue, 14 Jun 2016 18:05:38 -0700
Message-ID: <20160614180538.3d22d86f@xeon-e3>
References: <20160529182713.2131-1-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	clemens.gruber@pqgruber.com
To: Alexander Aring <aar@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36570 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893AbcFOBFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 21:05:25 -0400
Received: by mail-pf0-f175.google.com with SMTP id t190so2848164pfb.3
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 18:05:24 -0700 (PDT)
In-Reply-To: <20160529182713.2131-1-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 29 May 2016 20:27:13 +0200
Alexander Aring <aar@pengutronix.de> wrote:

> Since commit 5cd1adb ("Update to current iptables headers") the build
> with m_ipt.o and the following config will fail:
> 
> TC_CONFIG_XT:=n
> TC_CONFIG_XT_OLD:=n
> TC_CONFIG_XT_OLD_H:=n
> 
> This patch renames "iptables_target" to "xtables_target" and some other
> things which gets renamed and I noticed while reading iptables git log.
> Functions which are not used in m_ipt.c and not exported by the header
> are removed, if they still used in m_ipt.c I added a static to the function.
> 
> Reported-by: Clemens Gruber <clemens.gruber@pqgruber.com>
> Signed-off-by: Alexander Aring <aar@pengutronix.de>

Applied.
Not sure why this never showed up in patchwork.
