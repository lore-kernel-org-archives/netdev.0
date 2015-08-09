From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v4 4/4] gre: Remove support for sharing GRE
 protocol hook.
Date: Sun, 9 Aug 2015 18:34:34 +0200
Message-ID: <20150809163434.GG3113@pox.localdomain>
References: <1438830766-6602-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35296 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933071AbbHIQeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2015 12:34:36 -0400
Received: by wibxm9 with SMTP id xm9so113117433wib.0
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2015 09:34:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1438830766-6602-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/15 at 08:12pm, Pravin B Shelar wrote:
> Support for sharing GREPROTO_CISCO port was added so that
> OVS gre port and kernel GRE devices can co-exist. After
> flow-based tunneling patches OVS GRE protocol processing
> is completely moved to ip_gre module. so there is no need
> for GRE protocol hook. Following patch consolidates
> GRE protocol related functions into ip_gre module.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

LGTM

Acked-by: Thomas Graf <tgraf@suug.ch>
