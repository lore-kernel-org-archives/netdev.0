From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v3 net-next 5/8] geneve: Add support to collect tunnel
 metadata.
Date: Tue, 25 Aug 2015 20:12:36 +0200
Message-ID: <20150825181236.GF3707@pox.localdomain>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
 <1440438195-5695-6-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:38903 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755756AbbHYSMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 14:12:39 -0400
Received: by wicja10 with SMTP id ja10so22522857wic.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 11:12:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1440438195-5695-6-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/15 at 10:43am, Pravin B Shelar wrote:
> +	if (ip_tunnel_collect_metadata() && geneve->collect_md) {
> +		__be16 flags;
> +		void *opts;
> +

I think this should be ||
