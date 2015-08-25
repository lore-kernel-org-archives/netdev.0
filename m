From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v3 net-next 7/8] geneve: Consolidate Geneve functionality
 in single module.
Date: Tue, 25 Aug 2015 20:19:15 +0200
Message-ID: <20150825181915.GG3707@pox.localdomain>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
 <1440438195-5695-8-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37020 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbbHYSTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 14:19:17 -0400
Received: by widdq5 with SMTP id dq5so22699336wid.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 11:19:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1440438195-5695-8-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/15 at 10:43am, Pravin B Shelar wrote:
> -	if (ip_tunnel_collect_metadata() && geneve->collect_md) {
> +	if (ip_tunnel_collect_metadata() || gs->collect_md) {

OK, what I pointed out in patch 5 is fixed here.

Metadata bits look good.

Acked-by: Thomas Graf <tgraf@suug.ch>
