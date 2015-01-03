From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 3/3] ss: Filtering logic changing, with fixes
Date: Sat, 3 Jan 2015 09:57:07 -0800
Message-ID: <20150103095707.37e69147@urahara>
References: <1420245877-11763-1-git-send-email-vadim4j@gmail.com>
	<1420245877-11763-4-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:44922 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbbACR5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2015 12:57:17 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so25703524pab.5
        for <netdev@vger.kernel.org>; Sat, 03 Jan 2015 09:57:16 -0800 (PST)
In-Reply-To: <1420245877-11763-4-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  3 Jan 2015 02:44:37 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> +struct filter default_dbs[MAX_DB] = {
> +	[TCP_DB] = {
> +		.states   = SS_CONN,
> +		.families = (1 << AF_INET) | (1 << AF_INET6),
> +	},

I like table driven code, so this is good. But please make
mark the table as const.
